//
//  BoardCellTests.swift
//  ReversiTests
//
//  Created by Yoshimasa Aoki on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class BoardCellTests: XCTestCase {
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    func testEncodeWhenDarkDisk() {
        let expected = "{\"disk\":{\"rawValue\":\"x\"},\"position\":{\"x\":3,\"y\":5}}"
        let cell = BoardCell(position: Position(x: 3, y: 5), disk: .dark)
        guard let encoded = try? encoder.encode(cell),
            let actual = String(data: encoded, encoding: .utf8) else {
            fatalError("Could not encode the BoardCell")
        }

        XCTAssertEqual(actual, expected)
    }

    func testEncodeWhenLightDisk() {
        let expected = "{\"disk\":{\"rawValue\":\"o\"},\"position\":{\"x\":4,\"y\":2}}"
        let cell = BoardCell(position: Position(x: 4, y: 2), disk: .light)
        guard let encoded = try? encoder.encode(cell),
            let actual = String(data: encoded, encoding: .utf8) else {
                fatalError("Could not encode the BoardCell")
        }

        XCTAssertEqual(actual, expected)
    }

    func testEncodeWhenDiskIsNull() {
        let expected = "{\"disk\":\"-\",\"position\":{\"x\":1,\"y\":3}}"
        let cell = BoardCell(position: Position(x: 1, y: 3), disk: nil)
        guard let encoded = try? encoder.encode(cell),
            let actual = String(data: encoded, encoding: .utf8) else {
                fatalError("Could not encode the BoardCell")
        }

        XCTAssertEqual(actual, expected)
    }
}
