//
//  PlayerTypeTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class PlayerTypeTests: XCTestCase {
    // MARK: - test for player

    func testPlayerWhenManual() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let actual = PlayerType.manual.player(with: gameState)
        XCTAssertTrue(actual is Human)
    }

    func testPlayerWhenComputer() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let actual = PlayerType.computer.player(with: gameState)
        XCTAssertTrue(actual is Computer)
    }

    // MARK: - test for from

    func testFromWhenManual() {
        let actual = PlayerType.from(index: 0)
        XCTAssertEqual(actual, .manual)
    }

    func testFromWhenComputer() {
        let actual = PlayerType.from(index: 1)
        XCTAssertEqual(actual, .computer)
    }

    func testFromWhenOther() {
        let actual = PlayerType.from(index: 2)
        XCTAssertEqual(actual, .manual)
    }
}
