//
//  GameUseCaseTests.swift
//  ReversiUseCaseTests
//
//  Created by yoshimasa36g on 2020/05/25.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiEntity
@testable import ReversiUseCase
import XCTest

final class GameUseCaseTests: XCTestCase {
    private var subject: GameUseCase?
    private var presenter: MockPresenter?
    private var gateway: MockGateway?

    override func setUp() {
        super.setUp()
        let presenter = MockPresenter()
        self.presenter = presenter
        let gateway = MockGateway()
        self.gateway = gateway
        subject = GameUseCase(presenter: presenter, gateway: gateway)
    }

    // MARK: - test for startGame

    // gatewayのloadが呼ばれること
    func testStartGame() {
        subject?.startGame()
        XCTAssertEqual(gateway?.isLoadCalled, true)
    }

    // MARK: - test for dataLoaded(result:)

    // ロード成功のデータを渡した場合
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのgameReloadedメソッドが呼ばれること
    // - presenterのmessageChangedメソッドが呼ばれること
    // - presenterのdiscCountChangedメソッドが呼ばれること
    func testDataLoadedWhenSucceed() {
        let expectedData = randomGameStateData()
        subject?.dataLoaded(result: .success(expectedData))
        XCTAssertEqual(gateway?.data?.count, expectedData.count)
        XCTAssertEqual(presenter?.state?.discs.count, 64)
        XCTAssertNotNil(presenter?.label)
        XCTAssertEqual((presenter?.dark ?? 0) + (presenter?.light ?? 0), 64)
    }

    // ロード失敗のエラーを渡した場合
    // - ゲームの状態がリセットされること
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのgameReloadedメソッドが呼ばれること
    // - presenterのmessageChangedメソッドが呼ばれること
    // - presenterのdiscCountChangedメソッドが呼ばれること
    func testDataLoadedWhenFailed() {
        subject?.dataLoaded(result: .failure(.loadFailed))
        assertInitialGameState()
    }

    // MARK: - test for resetGame

    // - ゲームの状態がリセットされること
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのgameReloadedメソッドが呼ばれること
    // - presenterのmessageChangedメソッドが呼ばれること
    // - presenterのdiscCountChangedメソッドが呼ばれること
    func testResetGame() {
        subject?.dataLoaded(result: .success(randomGameStateData()))
        subject?.resetGame()
        assertInitialGameState()
    }

    // MARK: - helper methods

    private func assertInitialGameState() {
        let expectedData = try? JSONEncoder().encode(Game(turn: .dark()))
        XCTAssertEqual(gateway?.data?.count, expectedData?.count)
        XCTAssertEqual(presenter?.state?.turn, 0)
        XCTAssertEqual(presenter?.state?.players.dark, 0)
        XCTAssertEqual(presenter?.state?.players.light, 0)
        XCTAssertEqual(presenter?.state?.discs.count, 4)
        XCTAssertEqual(presenter?.state?.discs.contains(OutputDisc(color: 1, x: 3, y: 3)), true)
        XCTAssertEqual(presenter?.state?.discs.contains(OutputDisc(color: 0, x: 3, y: 4)), true)
        XCTAssertEqual(presenter?.state?.discs.contains(OutputDisc(color: 0, x: 4, y: 3)), true)
        XCTAssertEqual(presenter?.state?.discs.contains(OutputDisc(color: 1, x: 4, y: 4)), true)
        XCTAssertEqual(presenter?.color, 0)
        XCTAssertEqual(presenter?.label, "'s turn")
        XCTAssertEqual(presenter?.dark, 2)
        XCTAssertEqual(presenter?.light, 2)
    }

    private func randomDisc() -> Disc {
        [Disc.dark(), Disc.light()].randomElement() ?? .dark()
    }

    private func randomPlayer() -> Player {
        let type = [PlayerType.manual, PlayerType.computer].randomElement() ?? .manual
        return  type.toPlayer()
    }

    private func randomGameBoard() -> GameBoard {
        let cells = (0..<8).flatMap({ x in
            (0..<8).map { y in
                BoardCell(coordinate: Coordinate(x: x, y: y), disc: randomDisc())
            }
        })
        return GameBoard(cells: Set(cells))
    }

    private func randomGameStateData() -> Data {
        let state = Game(turn: randomDisc(),
                         players: Players(darkPlayer: randomPlayer(), lightPlayer: randomPlayer()),
                         board: randomGameBoard())
        guard let data = try? JSONEncoder().encode(state) else {
            preconditionFailure("Couldn't create test data")
        }
        return data
    }
}

private final class MockPresenter: GameUseCaseOutput {
    var state: OutputGameState?
    var color: Int?
    var label: String?
    var dark: Int?
    var light: Int?

    func gameReloaded(state: OutputGameState) {
        self.state = state
    }

    func messageChanged(color: Int?, label: String) {
        self.color = color
        self.label = label
    }

    func discCountChanged(dark: Int, light: Int) {
        self.dark = dark
        self.light = light
    }
}

private final class MockGateway: GameUseCaseRequest {
    var data: Data?
    var isLoadCalled = false

    func save(_ data: Data) {
        self.data = data
    }

    func load() {
        isLoadCalled = true
    }
}
