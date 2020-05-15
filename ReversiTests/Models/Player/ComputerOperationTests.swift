//
//  ComputerOperationTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class ComputerOperationTests: XCTestCase {
    // 選択できる位置がある場合は選択された結果が返ること
    func testStartWhenExistsAvailablePositions() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let operation = ComputerOperation(operation: RandomPositionOperation(gameState: gameState, duration: 0))
        let expected = [
            Position(x: 5, y: 1), Position(x: 4, y: 2), Position(x: 2, y: 5), Position(x: 2, y: 6),
            Position(x: 3, y: 6), Position(x: 4, y: 6), Position(x: 5, y: 6)
        ]

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        operation.start(
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .position(let position):
                    XCTAssertTrue(expected.contains(position))
                default:
                    XCTFail("invalid result")
                }
                completed.fulfill()
            })

        wait(for: [started, completed], timeout: 5)
    }

    // 選択できる位置がない場合は選択されなかった結果が返ること
    func testStartWhenNoAvailablePositions() {
        let gameState = GameState(turn: .dark, board: GameBoard(cells: []))
        let operation = ComputerOperation(operation: RandomPositionOperation(gameState: gameState, duration: 0))

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        operation.start(
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .noPosition:
                    break
                default:
                    XCTFail("invalid result")
                }
                completed.fulfill()
            })

        wait(for: [started, completed], timeout: 5)
    }

    // キャンセルされた場合はキャンセルされた結果が返ること
    func testStartWhenCancel() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let operation = ComputerOperation(operation: RandomPositionOperation(gameState: gameState, duration: 0))

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        operation.start(
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .cancel:
                    break
                default:
                    XCTFail("invalid result")
                }
                completed.fulfill()
            })

        operation.cancel()

        wait(for: [started, completed], timeout: 5)
    }
}
