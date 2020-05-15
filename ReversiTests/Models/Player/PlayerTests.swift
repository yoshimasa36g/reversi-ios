//
//  PlayerTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class PlayerTests: XCTestCase {
    // MARK: - test for operation

    func testOperationWhenManual() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let actual = Player.manual.operation(with: gameState)
        XCTAssertNil(actual)
    }

    func testOperationWhenComputer() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let actual = Player.computer.operation(with: gameState)
        XCTAssertNotNil(actual)
    }

    // MARK: - test for from

    func testFromWhenManual() {
        let actual = Player.from(index: 0)
        XCTAssertEqual(actual, .manual)
    }

    func testFromWhenComputer() {
        let actual = Player.from(index: 1)
        XCTAssertEqual(actual, .computer)
    }

    func testFromWhenOther() {
        let actual = Player.from(index: 2)
        XCTAssertEqual(actual, .manual)
    }
}
