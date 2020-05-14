@testable import Reversi
import XCTest

final class GameStateFileStoreTests: XCTestCase {
    private static let fileName = "GameStateForTest"

    private let subject = GameStateFileStore(fileName: fileName)

    private var path: String {
        guard let directory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            preconditionFailure()
        }
        return (directory as NSString).appendingPathComponent(GameStateFileStoreTests.fileName)
    }

    private let validFileContents =
        #"{"darkPlayer":0,"lightPlayer":1,"board":{"cells":["#
            + #"{"disk":"x","position":{"x":0,"y":0}},"#
            + #"{"disk":"x","position":{"x":2,"y":0}},"#
            + #"{"disk":"o","position":{"x":4,"y":0}},"#
            + #"{"disk":"x","position":{"x":1,"y":1}},"#
            + #"{"disk":"o","position":{"x":2,"y":1}},"#
            + #"{"disk":"o","position":{"x":3,"y":1}},"#
            + #"{"disk":"o","position":{"x":4,"y":1}},"#
            + #"{"disk":"o","position":{"x":5,"y":1}}"#
            + #"]},"turn":"x"}"#

    private var validGameState: GameState {
        let turn: Disk = .dark
        let board = GameBoard(cells: [
            BoardCell(x: 0, y: 0, disk: .dark),
            BoardCell(x: 2, y: 0, disk: .dark),
            BoardCell(x: 4, y: 0, disk: .light),
            BoardCell(x: 1, y: 1, disk: .dark),
            BoardCell(x: 2, y: 1, disk: .light),
            BoardCell(x: 3, y: 1, disk: .light),
            BoardCell(x: 4, y: 1, disk: .light),
            BoardCell(x: 5, y: 1, disk: .light)
        ])
        return GameState(turn: turn, darkPlayer: .manual, lightPlayer: .computer, board: board)
    }

    func testSave() {
        try? subject.save(validGameState)
        let savedContents = try? String(contentsOfFile: path, encoding: .utf8)
        XCTAssertEqual(savedContents, validFileContents)
    }

    func testLoad() {
        try? validFileContents.write(toFile: path, atomically: true, encoding: .utf8)
        let state = try? subject.load()
        XCTAssertEqual(state, validGameState)
    }
}
