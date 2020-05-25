//
//  ComputerTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class ComputerTests: XCTestCase {
    // 選択できる位置がある場合は選択された結果が返ること
    func testStartWhenExistsAvailableCoordinates() {
        let expected = Coordinate(x: Int.random(in: 0..<8), y: Int.random(in: 0..<8))
        let computer = Computer { _ in MockOperation(coordinate: expected) }

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: MockGameState(),
            onStart: { started.fulfill() },
            onComplete: { result in
                switch result {
                case .coordinate(let coordinate):
                    XCTAssertEqual(coordinate, expected)
                default:
                    XCTFail("invalid result")
                }
                completed.fulfill()
            })

        wait(for: [started, completed], timeout: 5)
    }

    // 選択できる位置がない場合はパスした結果が返ること
    func testStartWhenNoAvailableCoordinates() {
        let computer = Computer { _ in MockOperation() }

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: MockGameState(),
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
        let computer = Computer { _ in MockOperation(coordinate: Coordinate(x: 3, y: 5)) }

        let started = expectation(description: "onStart")
        let completed = expectation(description: "onComplete")

        computer.startOperation(
            gameState: MockGameState(),
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

private final class MockOperation: Operation, ComputerOperation {
    var coordinate: Coordinate?

    init(coordinate: Coordinate? = nil) {
        self.coordinate = coordinate
    }

    override func main() {
        sleep(1)

        if isCancelled {
            coordinate = nil
        }
    }
}

private struct MockGameState: GameState {
    let turn: Disc? = nil

    let players = Players(darkPlayer: Human(), lightPlayer: Human())

    let board = GameBoard(cells: [])

    var message: (disc: Disc?, label: String) = (disc: nil, label: "")

    func count(of disc: Disc) -> Int {
        return 0
    }

    func reset() -> GameState {
        return MockGameState()
    }

    func placeableCoordinates(disc: Disc) -> [Coordinate] {
        []
    }
}
