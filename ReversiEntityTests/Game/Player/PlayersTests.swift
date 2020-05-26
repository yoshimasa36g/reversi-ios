//
//  PlayersTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class PlayersTests: XCTestCase {
    private var subject = Players(darkPlayer: MockPlayer(), lightPlayer: MockPlayer())
    private var darkPlayer = MockPlayer()
    private var lightPlayer = MockPlayer()

    override func setUp() {
        super.setUp()
        self.darkPlayer = MockPlayer()
        self.lightPlayer = MockPlayer()
        self.subject = Players(darkPlayer: darkPlayer, lightPlayer: lightPlayer)
    }

    // MARK: - test for changePlayer

    // 黒のプレイヤーを変更する場合、黒のプレイヤーのみ変更されること
    func testChangePlayerWhenChangeDarkPlayer() {
        let actual = subject.changePlayer(of: .dark(), to: Computer())
        let expected = Players(darkPlayer: Computer(), lightPlayer: MockPlayer())
        XCTAssertEqual(actual, expected)
    }

    // 白のプレイヤーを変更する場合、白のプレイヤーのみ変更されること
    func testChangePlayerWhenChangeLightPlayer() {
        let actual = subject.changePlayer(of: .light(), to: Computer())
        let expected = Players(darkPlayer: MockPlayer(), lightPlayer: Computer())
        XCTAssertEqual(actual, expected)
    }

    // MARK: - test for startOperation

    // 黒のプレイヤーのターンの場合、黒のプレイヤーのみ操作が開始されること
    func testStartOperationWhenDarkPlayersTurn() {
        subject.startOperation(gameState: MockGameState(turn: .dark()), onStart: {}, onComplete: { _ in })
        XCTAssertTrue(darkPlayer.isStarted)
        XCTAssertFalse(lightPlayer.isStarted)
    }

    // 白のプレイヤーのターンの場合、白のプレイヤーのみ操作が開始されること
    func testStartOperationWhenLightPlayersTurn() {
        subject.startOperation(gameState: MockGameState(turn: .light()), onStart: {}, onComplete: { _ in })
        XCTAssertFalse(darkPlayer.isStarted)
        XCTAssertTrue(lightPlayer.isStarted)
    }

    // MARK: - test for cancelOperation

    // 黒のプレイヤーを指定した場合、黒のプレイヤーのみ操作がキャンセルされること
    func testCancelOperationWhenDarkPlayersTurn() {
        subject.cancelOperation(of: .dark())
        XCTAssertTrue(darkPlayer.isCancelled)
        XCTAssertFalse(lightPlayer.isCancelled)
    }

    // 白のプレイヤーを指定した場合、白のプレイヤーのみ操作がキャンセルされること
    func testCancelOperationWhenLightPlayersTurn() {
        subject.cancelOperation(of: .light())
        XCTAssertFalse(darkPlayer.isCancelled)
        XCTAssertTrue(lightPlayer.isCancelled)
    }

    // MARK: - test for cancelAll

    // すべてのプレイヤーの操作がキャンセルされること
    func testCancelAll() {
        subject.cancelAll()
        XCTAssertTrue(darkPlayer.isCancelled)
        XCTAssertTrue(lightPlayer.isCancelled)
    }

    // MARK: - test for type(of:)

    // 正しいプレイヤー区分が返ってくること
    func testTypeOf() {
        let subject = Players(darkPlayer: Human(), lightPlayer: Computer())
        XCTAssertEqual(subject.type(of: .dark()), .manual)
        XCTAssertEqual(subject.type(of: .light()), .computer)
    }
}

private class MockPlayer: Player {
    var type: PlayerType {
        .computer
    }

    var isStarted = false
    var isCancelled = false

    func startOperation(gameState: GameState, onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        isStarted = true
    }

    func cancelOperation() {
        isCancelled = true
    }
}

private class MockGameState: GameState {
    var isGameOver: Bool = false

    var currentPlayerType: PlayerType?

    var turn: Disc?

    let players = Players(darkPlayer: Human(), lightPlayer: Human())

    let board = GameBoard(cells: [])

    init(turn: Disc?) {
        self.turn = turn
    }

    var message: (disc: Disc?, label: String) = (disc: nil, label: "")

    func count(of disc: Disc) -> Int {
        return 0
    }

    func reset() -> GameState {
        return MockGameState(turn: nil)
    }

    func coordinatesOfGettableDiscs(by disc: Disc, at coordinate: Coordinate) -> [Coordinate] {
        return []
    }

    func placeableCoordinates(disc: Disc) -> [Coordinate] {
        return []
    }

    func place(disc: Disc, at coordinates: [Coordinate]) -> GameState {
        return MockGameState(turn: nil)
    }

    func changeTurn(to newTurn: Disc?) -> GameState {
        return MockGameState(turn: nil)
    }

    func changePlayer(of side: Disc, to newPlayer: Player) -> GameState {
        return MockGameState(turn: nil)
    }

    func isPlaceable(disc: Disc) -> Bool {
        return false
    }
}
