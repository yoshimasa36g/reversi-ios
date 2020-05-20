//
//  BoardCellTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class BoardCellTests: XCTestCase {
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    // MARK: - tests for encode

    func testEncodeWhenDarkDisk() {
        let expected = #"{"disk":"x","coordinate":{"x":3,"y":5}}"#
        let cell = BoardCell(x: 3, y: 5, disk: .dark)
        sharedExampleForEncode(target: cell, equalsTo: expected)
    }

    func testEncodeWhenLightDisk() {
        let expected = #"{"disk":"o","coordinate":{"x":4,"y":2}}"#
        let cell = BoardCell(x: 4, y: 2, disk: .light)
        sharedExampleForEncode(target: cell, equalsTo: expected)
    }

    private func sharedExampleForEncode(target cell: BoardCell, equalsTo expected: String) {
        guard let encoded = try? encoder.encode(cell),
            let actual = String(data: encoded, encoding: .utf8) else {
                fatalError("Could not encode the BoardCell")
        }

        XCTAssertEqual(actual, expected)
    }

    // MARK: - tests for decode

    func testDecodeWhenDarkDisk() {
        let source = #"{"disk":"x","coordinate":{"x":3,"y":5}}"#.data(using: .utf8) ?? Data()
        let expected = BoardCell(coordinate: Coordinate(x: 3, y: 5), disk: .dark)
        sharedExampleForDecode(target: source, equalsTo: expected)
    }

    func testDecodeWhenLightDisk() {
        let source = #"{"disk":"o","coordinate":{"x":4,"y":2}}"#.data(using: .utf8) ?? Data()
        let expected = BoardCell(coordinate: Coordinate(x: 4, y: 2), disk: .light)
        sharedExampleForDecode(target: source, equalsTo: expected)
    }

    private func sharedExampleForDecode(target source: Data, equalsTo expected: BoardCell) {
        let actual = try? decoder.decode(BoardCell.self, from: source)

        XCTAssertEqual(actual?.coordinate.x, expected.coordinate.x)
        XCTAssertEqual(actual?.coordinate.y, expected.coordinate.y)
        XCTAssertEqual(actual?.disk, expected.disk)
    }
}
