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

    // MARK: - test for reset

    // useCaseのresetGameを呼び出すこと
    func testReset() {
        subject?.reset()
        XCTAssertEqual(useCase?.isResetGameCalled, true)
    }
}

private final class MockUseCase: GameUseCaseInput {
    var isResetGameCalled = false

    func resetGame() {
        isResetGameCalled = true
    }
}
