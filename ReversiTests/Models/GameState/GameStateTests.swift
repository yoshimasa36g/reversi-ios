//
//  GameStateTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/11.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class GameStateTests: XCTestCase {

    // MARK: - tests for message

    func testMessageWhenDarksTurn() {
        let state = GameState(turn: .dark)
        let message = state.message
        XCTAssertEqual(message.disk, .dark)
        XCTAssertEqual(message.label, "'s turn")
    }

    func testMessageWhenLightsTurn() {
        let state = GameState(turn: .light)
        let message = state.message
        XCTAssertEqual(message.disk, .light)
        XCTAssertEqual(message.label, "'s turn")
    }

    func testMessageWhenDarkWins() {
        let cells = [BoardCell(x: 0, y: 0, disk: .dark)]
        let state = GameState(turn: nil, board: GameBoard(cells: cells))
        let message = state.message
        XCTAssertEqual(message.disk, .dark)
        XCTAssertEqual(message.label, " won")
    }

    func testMessageWhenLightWins() {
        let cells = [BoardCell(x: 0, y: 0, disk: .light)]
        let state = GameState(turn: nil, board: GameBoard(cells: cells))
        let message = state.message
        XCTAssertEqual(message.disk, .light)
        XCTAssertEqual(message.label, " won")
    }

    func testMessageWhenTied() {
        let state = GameState(turn: nil)
        let message = state.message
        XCTAssertNil(message.disk)
        XCTAssertEqual(message.label, "Tied")
    }

    // MARK: - test for isGameOver

    func testIsGameOverWhenGameIsOver() {
        let range = 0..<8
        let cells = range.flatMap { x in range.map { y in BoardCell(coordinate: Coordinate(x: x, y: y), disk: .dark) } }
        let state = GameState(board: GameBoard(cells: cells))
        XCTAssertTrue(state.isGameOver)
    }

    func testIsGameOverWhenGameIsNotOver() {
        let state = GameState(board: ModelsHelper.createGameBoard(advantage: .dark))
        XCTAssertFalse(state.isGameOver)
    }

    // MARK: - test for changeTurn(to:)

    // - 戻り地のGameStateのturnが変更されること
    // - 元のGameStateのturnは変更されないこと
    // - playersとboardに変更がないこと
    func testChangeTurn() {
        let example = { (oldTurn: Disk?, newTurn: Disk?) in
            let state = GameState(turn: oldTurn)
            let result = state.changeTurn(to: newTurn)
            XCTAssertEqual(result.turn, newTurn)
            XCTAssertEqual(state.turn, oldTurn)
            XCTAssertEqual(result.players, state.players)
            XCTAssertTrue(result.isSameBoard(as: state))
        }
        example(nil, .dark)
        example(.dark, .light)
        example(.light, nil)
    }

    // MARK: - test for changePlayer(side:to:)

    // - 戻り地のGameStateのplayersが変更されること
    // - 元のGameStateのplayersは変更されないこと
    // - turnとboardに変更がないこと
    func testChangePlayer() {
        let example = { (side: Disk, expected: Players) in
            let state = GameState()
            let result = state.changePlayer(of: side, to: Computer())
            XCTAssertEqual(result.players, expected)
            XCTAssertEqual(state.players, Players(darkPlayer: Human(), lightPlayer: Human()))
            XCTAssertEqual(result.turn, state.turn)
            XCTAssertTrue(result.isSameBoard(as: state))
        }
        example(.dark, Players(darkPlayer: Computer(), lightPlayer: Human()))
        example(.light, Players(darkPlayer: Human(), lightPlayer: Computer()))
    }

    // MARK: - test for place(disk:at:)

    // - 戻り地のGameStateの指定した位置にディスクが置かれていること
    // - 元のGameStateのboardは変更されないこと
    // - turnとplayersに変更がないこと
    // - GameBoardのメソッドを呼び出しているだけなので細かいパターンのテストはここでは実施しない
    func testPlaceDisk() {
        let state = GameState(turn: .dark)
        let coordinate = Coordinate(x: 1, y: 6)
        let result = state.place(disk: .dark, at: coordinate)
        XCTAssertEqual(result.disk(at: coordinate), .dark)
        XCTAssertTrue(state.isSameBoard(as: GameBoard(cells: GameBoard.initialCells)))
        XCTAssertEqual(result.turn, state.turn)
        XCTAssertEqual(result.players, state.players)
    }

    // MARK: - test for removeDisk(at:)

    // - 戻り地のGameStateの指定した位置からディスクが取り除かれていること
    // - 元のGameStateのboardは変更されないこと
    // - turnとplayersに変更がないこと
    // - GameBoardのメソッドを呼び出しているだけなので細かいパターンのテストはここでは実施しない
    func testRemoveDisk() {
        let state = GameState(turn: .dark)
        let coordinate = Coordinate(x: 4, y: 3)
        let result = state.removeDisk(at: coordinate)
        XCTAssertNil(result.disk(at: coordinate))
        XCTAssertTrue(state.isSameBoard(as: GameBoard(cells: GameBoard.initialCells)))
        XCTAssertEqual(result.turn, state.turn)
        XCTAssertEqual(result.players, state.players)
    }

    // MARK: - test for persistence methods

    // リポジトリのsaveメソッドが呼ばれること
    func testSave() {
        let repository = MockRepository()
        let state = GameState(turn: .light, board: ModelsHelper.createGameBoard(advantage: .dark))
        try? state.save(to: repository)
        XCTAssertEqual(repository.state, state)
    }

    // リポジトリのloadメソッドが呼ばれること
    func testLoad() {
        let repository = MockRepository()
        repository.state = GameState(turn: .light, board: ModelsHelper.createGameBoard(advantage: .dark))
        let result = try? GameState.load(from: repository)
        XCTAssertEqual(result, repository.state)
    }
}

private final class MockRepository: GameStateRepository {
    var state: GameState?

    func save(_ state: GameState) throws {
        self.state = state
    }

    func load() throws -> GameState {
        if let state = self.state {
            return state
        }
        throw RepositoryError()
    }
}

private struct RepositoryError: Error { }
