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

    // MARK: - test for specifyPlacingDiscCoordinate(x:y:)

    // presnterに獲得可能なディスクの座標を渡すこと
    func testSpecifyPlacingDiscCoordinate() {
        subject?.resetGame()
        subject?.specifyPlacingDiscCoordinate(x: 2, y: 3)
        XCTAssertEqual(presenter?.coordinates.count, 2)
        XCTAssertEqual(presenter?.coordinates.first?.x, 2)
        XCTAssertEqual(presenter?.coordinates.first?.y, 3)
        XCTAssertEqual(presenter?.coordinates.last?.x, 3)
        XCTAssertEqual(presenter?.coordinates.last?.y, 3)
    }

    // MARK: - test for changeDiscs(to:at:)

    // - 指定した座標のディスクを変更すること
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのgameReloadedメソッドが呼ばれること
    // - presenterのmessageChangedメソッドが呼ばれること
    // - presenterのdiscCountChangedメソッドが呼ばれること
    func testChangeDiscs() {
        let coordinates = allCoordinates().map { (x: $0.x, y: $0.y) }
        subject?.changeDiscs(to: DiscColor.light.rawValue, at: coordinates)
        XCTAssertNotNil(gateway?.data)
        XCTAssertEqual(presenter?.state?.discs.count, 64)
        XCTAssertNotNil(presenter?.label)
        XCTAssertEqual(presenter?.dark, 0)
        XCTAssertEqual(presenter?.light, 64)
    }

    // MARK: - test for continueGame()

    // ゲームが初期状態の場合
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのmessageChangedに次のターンのメッセージが渡ること
    func testContinueGameWhenInitialGame() {
        subject?.resetGame()
        gateway?.data = nil
        subject?.continueGame()
        XCTAssertNotNil(gateway?.data)
        XCTAssertEqual(presenter?.color, DiscColor.light.rawValue)
        XCTAssertEqual(presenter?.label, "'s turn")
    }

    // ゲームが終了状態の場合
    // - presenterのmessageChangedにゲーム終了のメッセージが渡ること
    // - 実際はchangeDiscsの時点で渡っているので、continueGameでは何も起きない
    func testContinueGameWhenGameIsOver() {
        subject?.resetGame()
        let coordinates = allCoordinates().map { (x: $0.x, y: $0.y) }
        subject?.changeDiscs(to: DiscColor.dark.rawValue, at: coordinates)
        subject?.continueGame()
        XCTAssertEqual(presenter?.color, DiscColor.dark.rawValue)
        XCTAssertEqual(presenter?.label, " won")
    }

    // ディスクを置ける場所がない場合
    // - gatewayのsaveメソッドが呼ばれること
    // - presenterのpassedが呼ばれること
    func testContinueGameWhenNoPlaceableCoordinate() {
        subject?.resetGame()
        gateway?.data = nil
        subject?.changeDiscs(to: DiscColor.dark.rawValue, at: [
            (x: 3, y: 3),
            (x: 5, y: 3),
            (x: 3, y: 5),
            (x: 4, y: 5),
            (x: 5, y: 5),
            (x: 5, y: 4)
        ])
        subject?.continueGame()
        XCTAssertNotNil(gateway?.data)
        XCTAssertEqual(presenter?.isPassedCalled, true)
    }

    // MARK: - test for changePlayerType(of:to:)

    // - gatewayのsaveメソッドが呼ばれること
    func testChangePlayerType() {
        subject?.resetGame()
        gateway?.data = nil
        subject?.changePlayerType(of: DiscColor.dark.rawValue, to: PlayerType.computer.rawValue)
        XCTAssertNotNil(gateway?.data)
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

    private func allCoordinates() -> [Coordinate] {
        (0..<8).flatMap({ x in (0..<8).map { y in Coordinate(x: x, y: y) } })
    }

    private func randomGameBoard() -> GameBoard {
        let cells = allCoordinates().map { BoardCell(coordinate: $0, disc: randomDisc()) }
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
    var coordinates = [(x: Int, y: Int)]()

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

    func gettableCoordinates(color: Int, coordinates: [(x: Int, y: Int)]) {
        self.coordinates = coordinates
    }

    var isPassedCalled = false
    func passed() {
        isPassedCalled = true
    }

    func thinkingStarted(color: Int) {
    }

    func thinkingStopped(color: Int) {
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
