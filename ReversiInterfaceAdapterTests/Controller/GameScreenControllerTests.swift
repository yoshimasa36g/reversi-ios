//
//  GameScreenControllerTests.swift
//  ReversiInterfaceAdapterTests
//
//  Created by yoshimasa36g on 2020/05/25.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiInterfaceAdapter
import ReversiUseCase
import XCTest

final class GameScreenControllerTests: XCTestCase {
    private var useCase: MockUseCase?
    private var subject: GameScreenController?

    override func setUp() {
        super.setUp()
        let useCase = MockUseCase()
        self.useCase = useCase
        subject = GameScreenController(useCase: useCase)
    }

    // MARK: - test for start

    // useCaseのstartGameを呼び出すこと
    func testStart() {
        subject?.start()
        XCTAssertEqual(useCase?.isStartGameCalled, true)
    }

    // MARK: - test for reset

    // useCaseのresetGameを呼び出すこと
    func testReset() {
        subject?.reset()
        XCTAssertEqual(useCase?.isResetGameCalled, true)
    }

    // MARK: - test for specifyPlacingDiscCoordinate(x:y:)

    // useCaseのspecifyPlacingDiscCoordinateに座標を渡すこと
    func testSpecifyPlacingDiscCoordinate() {
        let x = Int.random(in: 0..<8)
        let y = Int.random(in: 0..<8)
        subject?.specifyPlacingDiscCoordinate(x: x, y: y)
        XCTAssertEqual(useCase?.x, x)
        XCTAssertEqual(useCase?.y, y)
    }

    // MARK: - testChangeDiscsCompleted(color:at:)

    // useCaseのchangeDiscsにディスクの色IDと座標の一覧を渡すこと
    func testChangeDiscsCompleted() {
        let color = Int.random(in: 0...1)
        let coordinates = (0..<64).map { _ in (x: Int.random(in: 0..<8), y: Int.random(in: 0..<8)) }
        subject?.changeDiscsCompleted(color: color, at: coordinates)
        XCTAssertEqual(useCase?.color, color)
        XCTAssertEqual(useCase?.coordinates.elementsEqual(coordinates, by: { actual, expected in
            actual.x == expected.x && actual.y == expected.y
        }), true)
    }

    // MARK: - test for acceptPass

    // useCaseのcontinueGameを呼び出すこと
    func testAcceptPass() {
        subject?.acceptPass()
        XCTAssertEqual(useCase?.isContinueGameCalled, true)
    }

    // MARK: - test for changePlayerType(of:to:)

    // useCaseのchangePlayerTypeにディスクの色IDとプレイヤー区分を渡すこと
    func testChangePlayerType() {
        let color = Int.random(in: 0...1)
        let playerType = Int.random(in: 0...1)
        subject?.changePlayerType(of: color, to: playerType)
        XCTAssertEqual(useCase?.color, color)
        XCTAssertEqual(useCase?.playerType, playerType)
    }
}

private final class MockUseCase: GameUseCaseInput {
    var isStartGameCalled = false
    func startGame() {
        isStartGameCalled = true
    }

    var isResetGameCalled = false
    func resetGame() {
        isResetGameCalled = true
    }

    var x: Int?
    var y: Int?
    func specifyPlacingDiscCoordinate(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    func tryPlacingDisc(color: Int, x: Int, y: Int) {
    }

    var color: Int?
    var coordinates = [(x: Int, y: Int)]()
    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)]) {
        self.color = color
        self.coordinates = coordinates
    }

    var isContinueGameCalled = false
    func continueGame() {
        isContinueGameCalled = true
    }

    var playerType: Int?
    func changePlayerType(of color: Int, to playerType: Int) {
        self.color = color
        self.playerType = playerType
    }
}
