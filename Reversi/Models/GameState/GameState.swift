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

    /// プレイヤー情報
    let players: Players

    /// ゲーム盤
    let board: GameBoard

    init(turn: Disk? = nil,
         players: Players = Players(darkPlayer: Human(), lightPlayer: Human()),
         board: GameBoard = GameBoard(cells: GameBoard.initialCells)
    ) {
        self.turn = turn
        self.players = players
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

    // MARK: - Codable

    enum Key: CodingKey {
        case turn
        case darkPlayer
        case lightPlayer
        case board
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        turn = try container.decodeIfPresent(Disk.self, forKey: .turn)
        board = try container.decode(GameBoard.self, forKey: .board)
        let dark = try container.decode(PlayerType.self, forKey: .darkPlayer).toPlayer()
        let light = try container.decode(PlayerType.self, forKey: .lightPlayer).toPlayer()
        players = Players(darkPlayer: dark, lightPlayer: light)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encodeIfPresent(turn, forKey: .turn)
        try container.encode(players.type(of: .dark), forKey: .darkPlayer)
        try container.encode(players.type(of: .light), forKey: .lightPlayer)
        try container.encode(board, forKey: .board)
    }
}

// MARK: - Equatable

extension GameState: Equatable {
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        return lhs.turn == rhs.turn
            && lhs.players == rhs.players
            && lhs.board == rhs.board
    }
}
