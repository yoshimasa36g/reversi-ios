//
//  GameStateFileStore.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation
import ReversiInterfaceAdapter
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

    func save(_ data: Data) throws {
        guard let output = String(data: data, encoding: .utf8) else {
            throw encodeError(with: data)
        }

        do {
            try output.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error {
            throw FileIOError.write(path: path, cause: error)
        }
    }

    func load() throws -> Data {
        do {
            let fileContents = try String(contentsOfFile: path, encoding: .utf8)
            guard let data = fileContents.data(using: .utf8) else {
                throw FileIOError.read(path: path, cause: nil)
            }
            return data
        } catch let error {
            throw FileIOError.read(path: path, cause: error)
        }
    }

    private func encodeError(with data: Data) -> Error {
        EncodingError.invalidValue(data, .init(codingPath: [], debugDescription: "Could't encode the data"))
    }
}

enum FileIOError: Error {
    case write(path: String, cause: Error?)
    case read(path: String, cause: Error?)
}
