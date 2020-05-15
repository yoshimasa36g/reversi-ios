//
//  GameBoardTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/11.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class GameBoardTests: XCTestCase {

    // MARK: - tests for count(of:)

    func testCountOf() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let darkCount = board.count(of: .dark)
        let lightCount = board.count(of: .light)
        XCTAssertEqual(darkCount, 7)
        XCTAssertEqual(lightCount, 5)
    }

    // MARK: - tests for winner()

    func testWinnerWhenDarkWins() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        XCTAssertEqual(board.winner(), .dark)
    }

    func testWinnerWhenLightWins() {
        let board = ModelsHelper.createGameBoard(advantage: .light)
        XCTAssertEqual(board.winner(), .light)
    }

    func testWinnerWhenTieGame() {
        let board = ModelsHelper.createTieGameBoard()
        XCTAssertNil(board.winner())
    }

    // MARK: - test for filp

    let flipTestInputs: [BoardCell] = [
        BoardCell(x: 4, y: 6, disk: .dark),
        BoardCell(x: 2, y: 6, disk: .dark),
        BoardCell(x: 1, y: 3, disk: .light),
        BoardCell(x: 4, y: 2, disk: .dark),
        BoardCell(x: 6, y: 2, disk: .light),
        BoardCell(x: 5, y: 4, disk: .light),
        BoardCell(x: 5, y: 4, disk: .dark),
        BoardCell(x: 1, y: 6, disk: .dark)
    ]

    let flipTestExpecteds: [[Position]] = [
        [Position(x: 3, y: 5), Position(x: 4, y: 5)],
        [Position(x: 3, y: 5)],
        [Position(x: 2, y: 3), Position(x: 3, y: 3), Position(x: 2, y: 4)],
        [Position(x: 4, y: 3)],
        [Position(x: 5, y: 3), Position(x: 4, y: 4)],
        [Position(x: 5, y: 3), Position(x: 4, y: 4)],
        [],
        []
    ]

    func testPositionsOfDisksToBeAcquired() {
        zip(flipTestInputs, flipTestExpecteds).forEach { input, expected in
            let board = ModelsHelper.createGameBoard(advantage: .dark)
            let result = board.positionsOfDisksToBeAcquired(by: input.disk,
                                                            at: input.position)
            XCTAssertEqual(result, expected)
        }
    }

    func testIsSettableWhenSettable() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.isSettable(disk: .dark, at: Position(x: 4, y: 6))
        XCTAssertTrue(result)
    }

    func testIsSettableWhenUnsettable() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.isSettable(disk: .dark, at: Position(x: 1, y: 6))
        XCTAssertFalse(result)
    }

    func testSettablePositionsWhenDarkTurn() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.settablePositions(disk: .dark)
        let expected = [
            Position(x: 5, y: 1),
            Position(x: 4, y: 2),
            Position(x: 2, y: 5),
            Position(x: 2, y: 6),
            Position(x: 3, y: 6),
            Position(x: 4, y: 6),
            Position(x: 5, y: 6)
        ]
        XCTAssertEqual(result, expected)
    }

    func testSettablePositionsWhenLightTurn() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.settablePositions(disk: .light)
        let expected = [
            Position(x: 1, y: 2),
            Position(x: 3, y: 2),
            Position(x: 6, y: 2),
            Position(x: 1, y: 3),
            Position(x: 6, y: 3),
            Position(x: 1, y: 4),
            Position(x: 5, y: 4),
            Position(x: 6, y: 5)
        ]
        XCTAssertEqual(result, expected)
    }

    // MARK: - helper methods
}
