//
//  GameTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class GameTests: XCTestCase {

    // MARK: - tests for message

    func testMessageWhenDarksTurn() {
        let game = Game(turn: .dark())
        let message = game.message
        XCTAssertEqual(message.disc, .dark())
        XCTAssertEqual(message.label, "'s turn")
    }

    func testMessageWhenLightsTurn() {
        let game = Game(turn: .light())
        let message = game.message
        XCTAssertEqual(message.disc, .light())
        XCTAssertEqual(message.label, "'s turn")
    }

    func testMessageWhenDarkWins() {
        let cells = Set([BoardCell(coordinate: Coordinate(x: 0, y: 0), disc: .dark())])
        let game = Game(turn: nil, board: GameBoard(cells: cells))
        let message = game.message
        XCTAssertEqual(message.disc, .dark())
        XCTAssertEqual(message.label, " won")
    }

    func testMessageWhenLightWins() {
        let cells = Set([BoardCell(coordinate: Coordinate(x: 0, y: 0), disc: .light())])
        let game = Game(turn: nil, board: GameBoard(cells: cells))
        let message = game.message
        XCTAssertEqual(message.disc, .light())
        XCTAssertEqual(message.label, " won")
    }

    func testMessageWhenTied() {
        let game = Game(turn: nil)
        let message = game.message
        XCTAssertNil(message.disc)
        XCTAssertEqual(message.label, "Tied")
    }

    // MARK: - test for isGameOver

    func testIsGameOverWhenGameIsOver() {
        let range = 0..<8
        let cells = range.flatMap { x in
            range.map { y in BoardCell(coordinate: Coordinate(x: x, y: y), disc: .dark()) }
        }
        let game = Game(board: GameBoard(cells: Set(cells)))
        XCTAssertTrue(game.isGameOver)
    }

    func testIsGameOverWhenGameIsNotOver() {
        let game = Game(board: GameBoardFactory.create(advantage: .dark))
        XCTAssertFalse(game.isGameOver)
    }

    // MARK: - test for changeTurn(to:)

    // - 戻り値のGameのturnが変更されること
    // - 元のGameのturnは変更されないこと
    // - playersとboardに変更がないこと
    func testChangeTurn() {
        let example = { (oldTurn: Disc?, newTurn: Disc?) in
            let origin = Game(turn: oldTurn)
            let expected = Game(turn: newTurn, players: origin.players, board: origin.board)
            let actual = origin.changeTurn(to: newTurn)
            XCTAssertEqual(actual, expected)
            XCTAssertEqual(origin.turn, oldTurn)
        }
        example(nil, .dark())
        example(.dark(), .light())
        example(.light(), nil)
    }

    // MARK: - test for changePlayer(side:to:)

    // - 戻り値のGameのplayersが変更されること
    // - 元のGameのplayersは変更されないこと
    // - turnとboardに変更がないこと
    func testChangePlayer() {
        let example = { (side: Disc, expectedPlayers: Players) in
            let origin = Game()
            let expected = Game(turn: origin.turn, players: expectedPlayers, board: origin.board)
            let actual = origin.changePlayer(of: side, to: Computer())
            XCTAssertEqual(actual, expected)
            XCTAssertEqual(origin.players, Players(darkPlayer: Human(), lightPlayer: Human()))
        }
        example(.dark(), Players(darkPlayer: Computer(), lightPlayer: Human()))
        example(.light(), Players(darkPlayer: Human(), lightPlayer: Computer()))
    }

    // MARK: - test for place(disk:at:)

    // - 戻り値のGameの指定した位置にディスクが置かれていること
    // - 元のGameのboardは変更されないこと
    // - turnとplayersに変更がないこと
    // - GameBoardのメソッドを呼び出しているだけなので細かいパターンのテストはここでは実施しない
    func testPlaceDisk() {
        let origin = Game(turn: .dark())
        let coordinate = Coordinate(x: 1, y: 6)
        let expectedCells = Set(GameBoard.initialCells + [BoardCell(coordinate: coordinate, disc: .dark())])
        let expected = Game(turn: origin.turn, players: origin.players, board: GameBoard(cells: expectedCells))
        let actual = origin.place(disc: .dark(), at: coordinate)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(origin.board, GameBoard(cells: Set(GameBoard.initialCells)))
    }

    // MARK: - test for removeDisk(at:)

    // - 戻り値のGameの指定した位置からディスクが取り除かれていること
    // - 元のGameのboardは変更されないこと
    // - turnとplayersに変更がないこと
    // - GameBoardのメソッドを呼び出しているだけなので細かいパターンのテストはここでは実施しない
    func testRemoveDisk() {
        let origin = Game(turn: .dark())
        let coordinate = Coordinate(x: 4, y: 3)
        let expectedCells = Set(GameBoard.initialCells.filter { !$0.isIn(coordinate) })
        let expected = Game(turn: origin.turn, players: origin.players, board: GameBoard(cells: expectedCells))
        let actual = origin.removeDisc(at: coordinate)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(origin.board, GameBoard(cells: Set(GameBoard.initialCells)))
    }
}
