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
}

private final class MockUseCase: GameUseCaseInput {
    var isStartGameCalled = false
    var isResetGameCalled = false

    func startGame() {
        isStartGameCalled = true
    }

    func resetGame() {
        isResetGameCalled = true
    }

    func specifyPlacingDiscCoordinate(x: Int, y: Int) {
    }

    func tryPlacingDisc(color: Int, x: Int, y: Int) {
    }

    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)]) {
    }

    func continueGame() {
    }

    func changePlayerType(of color: Int, to playerType: Int) {
    }
}
