//
//  ComputerTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class ComputerTests: XCTestCase {
    // 選択できる位置がある場合は選択された結果が返ること
    func testStartWhenExistsAvailableCoordinates() {
        let gameState = GameState(turn: .dark, board: ModelsHelper.createGameBoard(advantage: .dark))
        let computer = Computer()
        let expected = [
            Coordinate(x: 5, y: 1), Coordinate(x: 4, y: 2), Coordinate(x: 2, y: 5), Coordinate(x: 2, y: 6),
            Coordinate(x: 3, y: 6), Coordinate(x: 4, y: 6), Coordinate(x: 5, y: 6)
        ]

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: gameState,
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .coordinate(let coordinate):
                    XCTAssertTrue(expected.contains(coordinate))
                default:
                    XCTFail("invalid result")
                }
                completed.fulfill()
            })

        wait(for: [started, completed], timeout: 5)
    }

    // 選択できる位置がない場合はパスした結果が返ること
    func testStartWhenNoAvailableCoordinates() {
        let gameState = GameState(turn: .dark, board: GameBoard(cells: []))
        let computer = Computer()

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: gameState,
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .pass:
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
        let computer = Computer()

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: gameState,
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

        computer.cancelOperation()

        wait(for: [started, completed], timeout: 5)
    }
}
