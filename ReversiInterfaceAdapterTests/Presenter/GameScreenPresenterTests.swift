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

    // screenにゲームの状態を渡すこと
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

    // MARK: - test for messageChanged(color:label:)

    // screenにディスクの色IDとラベル文字列を渡すこと
    func testMessageChanged() {
        let color = Int.random(in: 0...1)
        let label = UUID().uuidString
        subject?.messageChanged(color: color, label: label)
        XCTAssertEqual(screen?.color, color)
        XCTAssertEqual(screen?.label, label)
    }

    // MARK: - test for discCountChanged(dark:light:)

    // screenにディスクの枚数を渡すこと
    func testDiscCountChanged() {
        let dark = Int.random(in: 0...64)
        let light = 64 - dark
        subject?.discCountChanged(dark: dark, light: light)
        XCTAssertEqual(screen?.dark, dark)
        XCTAssertEqual(screen?.light, light)
    }

    // MARK: - test for gettableCoordinates(color:coordinates:)

    // screenにディスクの色IDと座標の一覧を渡すこと
    func testGettableCoordintes() {
        let color = Int.random(in: 0...1)
        let coordinates = (0..<64).map { _ in (x: Int.random(in: 0..<8), y: Int.random(in: 0..<8)) }
        subject?.gettableCoordinates(color: color, coordinates: coordinates)
        XCTAssertEqual(screen?.color, color)
        XCTAssertEqual(screen?.coordinates.elementsEqual(coordinates, by: { actual, expected in
            actual.x == expected.x && actual.y == expected.y
        }), true)
    }

    // MARK: - test for passed

    // screenのshowPassedMessageが呼ばれること
    func testPassed() {
        subject?.passed()
        XCTAssertEqual(screen?.isShowPassedMessageCalled, true)
    }

    // MARK: - test for thinkingStarted(color:)

    // screenのshowIndicatorにディスクの色IDを渡すこと
    func testThinkingStarted() {
        let color = Int.random(in: 0...1)
        subject?.thinkingStarted(color: color)
        XCTAssertEqual(screen?.color, color)
    }

    // MARK: - test for thinkingStopped(color:)

    // screenのhideIndicatorにディスクの色IDを渡すこと
    func testThinkingStopped() {
        let color = Int.random(in: 0...1)
        subject?.thinkingStopped(color: color)
        XCTAssertEqual(screen?.color, color)
    }
}

private final class MockScreen: GameScreenPresentable {
    var state: PresentableGameState?
    var color: Int?
    var label: String?
    var dark: Int?
    var light: Int?

    func redrawEntireGame(state: PresentableGameState) {
        self.state = state
    }

    func redrawMessage(color: Int?, label: String) {
        self.color = color
        self.label = label
    }

    func redrawDiscCount(dark: Int, light: Int) {
        self.dark = dark
        self.light = light
    }

    func flipDiscs(at coordinates: [(x: Int, y: Int)]) {
    }

    var coordinates = [(x: Int, y: Int)]()
    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)]) {
        self.color = color
        self.coordinates = coordinates
    }

    var isShowPassedMessageCalled = false
    func showPassedMessage() {
        isShowPassedMessageCalled = true
    }

    func showIndicator(for color: Int) {
        self.color = color
    }

    func hideIndicator(for color: Int) {
        self.color = color
    }
}
