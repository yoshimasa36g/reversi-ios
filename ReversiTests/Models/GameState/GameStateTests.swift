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
            XCTAssertEqual(result.board, state.board)
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
            XCTAssertEqual(result.board, state.board)
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
        let position = Position(x: 1, y: 6)
        let result = state.place(disk: .dark, at: position)
        XCTAssertEqual(result.board.disk(at: position), .dark)
        XCTAssertEqual(state.board, GameBoard(cells: GameBoard.initialCells))
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
        let position = Position(x: 4, y: 3)
        let result = state.removeDisk(at: position)
        XCTAssertNil(result.board.disk(at: position))
        XCTAssertEqual(state.board, GameBoard(cells: GameBoard.initialCells))
        XCTAssertEqual(result.turn, state.turn)
        XCTAssertEqual(result.players, state.players)
    }

    // MARK: - ViewControllerのリファクタリング対象メソッドのテスト 不要になったら消す

    private let helper = ViewControllerHelper()

    func testUpdateCountLabelsOnViewController() {
        helper.runGame(advantage: .dark)
        let vc = helper.viewController
        vc.updateCountLabels()
        XCTAssertEqual(vc.countLabelForDark()?.text, "7")
        XCTAssertEqual(vc.countLabelForLight()?.text, "5")
    }

    func testUpdateMessageViewsWhenDarksTurn() {
        let vc = helper.viewController
        vc.changeTurn(to: .dark)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .dark)
        XCTAssertEqual(vc.getMessageLabel().text, "'s turn")
    }

    func testUpdateMessageViewsWhenLightsTurn() {
        let vc = helper.viewController
        vc.changeTurn(to: .light)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .light)
        XCTAssertEqual(vc.getMessageLabel().text, "'s turn")
    }

    func testUpdateMessageViewsWhenDarkWins() {
        helper.runGame(advantage: .dark)
        let vc = helper.viewController
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .dark)
        XCTAssertEqual(vc.getMessageLabel().text, " won")
    }

    func testUpdateMessageViewsWhenLightsWins() {
        helper.runGame(advantage: .light)
        let vc = helper.viewController
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .light)
        XCTAssertEqual(vc.getMessageLabel().text, " won")
    }

    func testUpdateMessageViewsWhenTied() {
        let vc = helper.viewController
        vc.newGame()
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 0)
        XCTAssertEqual(vc.getMessageLabel().text, "Tied")
    }
}
