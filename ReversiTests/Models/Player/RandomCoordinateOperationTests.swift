//
//  RandomCoordinateOperationTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class RandomCoordinateOperationTests: XCTestCase {
    // 選択できる位置がある場合は選択されること
    func testExecutionWhenExistsAvailableCoordinates() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let expected = [
            Coordinate(x: 5, y: 1),
            Coordinate(x: 4, y: 2),
            Coordinate(x: 2, y: 5),
            Coordinate(x: 2, y: 6),
            Coordinate(x: 3, y: 6),
            Coordinate(x: 4, y: 6),
            Coordinate(x: 5, y: 6)
        ]

        let operationWaiter = expectation(description: "wait")

        let queue = OperationQueue()
        let operation = RandomCoordinateOperation(gameState: gameState, duration: 0)
        queue.addOperation(operation)

        operation.completionBlock = {
            XCTAssertFalse(operation.isCancelled)
            XCTAssertTrue(expected.contains(operation.coordinate ?? Coordinate(x: -1, y: -1)))
            operationWaiter.fulfill()
        }

        wait(for: [operationWaiter], timeout: 5)
    }

    // 選択できる位置がない場合は選択されないこと
    func testExecutionWhenNoAvailableCoordinates() {
        let gameState = GameState(turn: .dark, board: GameBoard(cells: [
            BoardCell(x: 3, y: 3, disk: .dark),
            BoardCell(x: 3, y: 4, disk: .dark),
            BoardCell(x: 4, y: 3, disk: .dark),
            BoardCell(x: 4, y: 4, disk: .dark)
        ]))

        let operationWaiter = expectation(description: "wait")

        let queue = OperationQueue()
        let operation = RandomCoordinateOperation(gameState: gameState, duration: 0)
        queue.addOperation(operation)

        operation.completionBlock = {
            XCTAssertFalse(operation.isCancelled)
            XCTAssertNil(operation.coordinate)
            operationWaiter.fulfill()
        }

        wait(for: [operationWaiter], timeout: 5)
    }

    // キャンセルされた場合は選択されないこと
    func testExecutionWhenCancel() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))

        let operationWaiter = expectation(description: "wait")

        let queue = OperationQueue()
        let operation = RandomCoordinateOperation(gameState: gameState, duration: 0)
        queue.addOperation(operation)

        operation.completionBlock = {
            XCTAssertTrue(operation.isCancelled)
            XCTAssertNil(operation.coordinate)
            operationWaiter.fulfill()
        }

        operation.cancel()

        wait(for: [operationWaiter], timeout: 5)
    }

    // 既にゲーム終了している場合は選択されないこと
    func testExecutionWhenGameEnded() {
        let gameState = GameState(turn: nil, board: ModelsHelper.createGameBoard(advantage: .dark))

        let operationWaiter = expectation(description: "wait")

        let queue = OperationQueue()
        let operation = RandomCoordinateOperation(gameState: gameState, duration: 0)
        queue.addOperation(operation)

        operation.completionBlock = {
            XCTAssertFalse(operation.isCancelled)
            XCTAssertNil(operation.coordinate)
            operationWaiter.fulfill()
        }

        wait(for: [operationWaiter], timeout: 5)
    }
}
