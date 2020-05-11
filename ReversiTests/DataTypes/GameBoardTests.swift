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
        let board = createGameBoard(advantage: .dark)
        let darkCount = board.count(of: .dark)
        let lightCount = board.count(of: .light)
        XCTAssertEqual(darkCount, 7)
        XCTAssertEqual(lightCount, 5)
    }

    // MARK: - tests for winner()

    func testWinnerWhenDarkWins() {
        let board = createGameBoard(advantage: .dark)
        XCTAssertEqual(board.winner(), .dark)
    }

    func testWinnerWhenLightWins() {
        let board = createGameBoard(advantage: .light)
        XCTAssertEqual(board.winner(), .light)
    }

    func testWinnerWhenTieGame() {
        let board = createTieGameBoard()
        XCTAssertNil(board.winner())
    }

    // MARK: - helper methods

    private func createGameBoard(advantage: Disk) -> GameBoard {
        let advantages = (0..<7).map { BoardCell(x: $0, y: $0, disk: advantage) }
        let disadvantage: Disk = advantage == .dark ? .light : .dark
        let disadvantages = (0..<5).map { BoardCell(x: $0, y: $0, disk: disadvantage) }
        return GameBoard(cells: advantages + disadvantages)
    }

    private func createTieGameBoard() -> GameBoard {
        let dark = (0..<5).map { BoardCell(x: $0, y: $0, disk: .dark) }
        let light = (0..<5).map { BoardCell(x: $0, y: $0, disk: .light) }
        return GameBoard(cells: dark + light)
    }
}
