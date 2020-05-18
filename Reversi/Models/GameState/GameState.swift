//
//  GameState.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲームの状態
final class GameState: Codable {
    /// ターン
    let turn: Disk?

    /// 黒のプレイヤーの操作区分
    let darkPlayer: PlayerType

    /// 白のプレイヤーの操作区分
    let lightPlayer: PlayerType

    /// ゲーム盤
    let board: GameBoard

    init(turn: Disk? = nil,
         darkPlayer: PlayerType = .manual,
         lightPlayer: PlayerType = .manual,
         board: GameBoard = GameBoard(cells: GameBoard.initialCells)
    ) {
        self.turn = turn
        self.darkPlayer = darkPlayer
        self.lightPlayer = lightPlayer
        self.board = board
    }

    /// ターン表示や勝敗表示用のメッセージ
    var message: (disk: Disk?, label: String) {
        if let side = turn {
            return (disk: side, label: "'s turn")
        }
        if let winner = board.winner() {
            return (disk: winner, label: " won")
        }
        return (disk: nil, label: "Tied")
    }
}

// MARK: - Equatable

extension GameState: Equatable {
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        return lhs.turn == rhs.turn
            && lhs.darkPlayer == rhs.darkPlayer
            && lhs.lightPlayer == rhs.lightPlayer
            && lhs.board == rhs.board
    }
}
