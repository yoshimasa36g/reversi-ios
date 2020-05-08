//
//  GameStateFileStore.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation
import UIKit

final class GameStateFileStore: GameStateRepository {
    private let fileName: String

    init(fileName: String = "Game") {
        self.fileName = fileName
    }

    private var path: String {
        guard let directory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            preconditionFailure()
        }
        return (directory as NSString).appendingPathComponent(fileName)
    }

    func save(turn: Disk?, playerControls: [UISegmentedControl], boardView: BoardView) throws {
        var output: String = ""
        output += turn.symbol
        for side in Disk.sides {
            output += playerControls[side.index].selectedSegmentIndex.description
        }
        output += "\n"

        for y in boardView.yRange {
            for x in boardView.xRange {
                output += boardView.diskAt(x: x, y: y).symbol
            }
            output += "\n"
        }

        do {
            try output.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error {
            throw FileIOError.read(path: path, cause: error)
        }
    }

    func load(playerControls: [UISegmentedControl], boardView: BoardView, completion: (Disk?) -> Void) throws {
        let input = try String(contentsOfFile: path, encoding: .utf8)
        var lines: ArraySlice<Substring> = input.split(separator: "\n")[...]

        guard var line = lines.popFirst() else {
            throw FileIOError.read(path: path, cause: nil)
        }

        let turn = try parseTurn(symbol: line.popFirst())
        try parsePlayers(line: line, playerControls: playerControls)
        try parseBoard(lines: lines, boardView: boardView)

        completion(turn)
    }

    private func parseTurn(symbol: Character?) throws -> Disk? {
        guard let disk = Disk?(symbol: symbol?.description ?? "") else {
            throw FileIOError.read(path: path, cause: nil)
        }
        return disk
    }

    private func parsePlayers(line: Substring, playerControls: [UISegmentedControl]) throws {
        var mutableLine = line
        for side in Disk.sides {
            guard let playerSymbol = mutableLine.popFirst(),
                let playerNumber = Int(playerSymbol.description),
                let player = Player(rawValue: playerNumber)
                else {
                    throw FileIOError.read(path: path, cause: nil)
            }
            playerControls[side.index].selectedSegmentIndex = player.rawValue
        }
    }

    private func parseBoard(lines: ArraySlice<Substring>, boardView: BoardView) throws {
        var mutableLines = lines
        guard lines.count == boardView.height else {
            throw FileIOError.read(path: path, cause: nil)
        }

        var y = 0
        while let line = mutableLines.popFirst() {
            var x = 0
            for character in line {
                let disk = Disk?(symbol: "\(character)").flatMap { $0 }
                boardView.setDisk(disk, atX: x, y: y, animated: false)
                x += 1
            }
            guard x == boardView.width else {
                throw FileIOError.read(path: path, cause: nil)
            }
            y += 1
        }
        guard y == boardView.height else {
            throw FileIOError.read(path: path, cause: nil)
        }
    }

    enum FileIOError: Error {
        case write(path: String, cause: Error?)
        case read(path: String, cause: Error?)
    }
}

extension Optional where Wrapped == Disk {
    fileprivate init?<S: StringProtocol>(symbol: S) {
        switch symbol {
        case "x":
            self = .some(.dark)
        case "o":
            self = .some(.light)
        case "-":
            self = .none
        default:
            return nil
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .some(.dark):
            return "x"
        case .some(.light):
            return "o"
        case .none:
            return "-"
        }
    }
}
