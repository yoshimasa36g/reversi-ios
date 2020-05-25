//
//  GameScreenPresenterTests.swift
//  ReversiInterfaceAdapterTests
//
//  Created by yoshimasa36g on 2020/05/25.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiInterfaceAdapter
import ReversiUseCase
import XCTest

final class GameScreenPresenterTests: XCTestCase {
    private var subject: GameScreenPresenter?
    private var screen: MockScreen?

    override func setUp() {
        super.setUp()
        let screen = MockScreen()
        self.screen = screen
        subject = GameScreenPresenter(screen: screen)
    }

    // MARK: - test for gameReloaded(state:)

    // 画面にゲームの状態を渡すこと
    func testGameReloaded() {
        let output = OutputGameState(turn: 1, players: (dark: 0, light: 1), discs: [
            OutputDisc(color: 0, x: 0, y: 0),
            OutputDisc(color: 1, x: 1, y: 1),
            OutputDisc(color: 0, x: 2, y: 2)
        ])
        subject?.gameReloaded(state: output)
        let actual = screen?.state
        XCTAssertEqual(actual?.turn, 1)
        XCTAssertEqual(actual?.players.dark, 0)
        XCTAssertEqual(actual?.players.light, 1)
        XCTAssertEqual(actual?.discs[0], PresentableDisc(color: 0, x: 0, y: 0))
        XCTAssertEqual(actual?.discs[1], PresentableDisc(color: 1, x: 1, y: 1))
        XCTAssertEqual(actual?.discs[2], PresentableDisc(color: 0, x: 2, y: 2))
    }
}

private final class MockScreen: GameScreenPresentable {
    var state: PresentableGameState?

    func redrawEntireGame(state: PresentableGameState) {
        self.state = state
    }
}
