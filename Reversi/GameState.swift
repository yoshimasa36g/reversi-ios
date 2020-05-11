//
//  GameState.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲームの状態
struct GameState: Codable, Equatable {
    /// ターン
    let turn: Disk?

    /// 黒のプレイヤー操作区分
    let darkPlayer: Player

    /// 白のプレイヤーの操作区分
    let lightPlayer: Player

    /// ゲーム盤
    let board: GameBoard

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
