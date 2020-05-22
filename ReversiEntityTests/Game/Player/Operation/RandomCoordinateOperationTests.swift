//
//  RandomCoordinateOperationTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class RandomCoordinateOperationTests: XCTestCase {
    // 選択できる位置がある場合は選択されること
    func testExecutionWhenExistsAvailableCoordinates() {
        let gameState = MockGameState(turn: .dark())

        let operationWaiter = expectation(description: "wait")

        let queue = OperationQueue()
        let operation = RandomCoordinateOperation(gameState: gameState, duration: 0)
        queue.addOperation(operation)

        operation.completionBlock = {
            defer { operationWaiter.fulfill() }
            XCTAssertFalse(operation.isCancelled)
            guard let coordinate = operation.coordinate else {
                XCTFail("coordinate is null")
                return
            }
            XCTAssertTrue(MockGameState.placeableCoordinatesSample.contains(coordinate))
        }

        wait(for: [operationWaiter], timeout: 5)
    }

    // 選択できる位置がない場合は選択されないこと
    func testExecutionWhenNoAvailableCoordinates() {
        let gameState = MockGameState(turn: .dark(), placeable: [])

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
        let gameState = MockGameState(turn: .dark())

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
        let gameState = MockGameState(turn: nil)

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

private class MockGameState: GameState {
    let turn: Disc?

    let players = Players(darkPlayer: Human(), lightPlayer: Human())

    let board = GameBoard(cells: [])

    let placeable: [Coordinate]

    init(turn: Disc?, placeable: [Coordinate] = MockGameState.placeableCoordinatesSample) {
        self.turn = turn
        self.placeable = placeable
    }

    func placeableCoordinates(disc: Disc) -> [Coordinate] {
        return placeable
    }

    static let placeableCoordinatesSample = [
        Coordinate(x: 5, y: 1),
        Coordinate(x: 4, y: 2),
        Coordinate(x: 2, y: 5),
        Coordinate(x: 2, y: 6),
        Coordinate(x: 3, y: 6),
        Coordinate(x: 4, y: 6),
        Coordinate(x: 5, y: 6)
    ]
}
