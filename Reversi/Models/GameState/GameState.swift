//
//  GameState.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲームの状態
struct GameState: Codable {
    /// ターン
    let turn: Disk?

    /// プレイヤー情報
    let players: Players

    /// ゲーム盤
    private let board: GameBoard

    init(turn: Disk? = nil,
         players: Players = Players(darkPlayer: Human(), lightPlayer: Human()),
         board: GameBoard = GameBoard(cells: GameBoard.initialCells)
    ) {
        self.turn = turn
        self.players = players
        self.board = board
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

// MARK: - Properties

extension GameState {
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

    var isGameOver: Bool {
        board.settableCoordinates(disk: .dark).isEmpty
            && board.settableCoordinates(disk: .light).isEmpty
    }
}

// MARK: - Manage turn

extension GameState {
    /// ターンを変更したインスタンスを返す
    /// - Parameter newTurn: 変更後のターン
    func changeTurn(to newTurn: Disk?) -> GameState {
        GameState(turn: newTurn, players: players, board: board)
    }
}

// MARK: - Manage Players

extension GameState {
    /// 指定した側のプレイヤーを変更したインスタンスを返す
    /// - Parameters:
    ///   - side: 変更する側
    ///   - newPlayer: 変更後のプレイヤー
    func changePlayer(of side: Disk, to newPlayer: Player) -> GameState {
        let newPlayers = players.changePlayer(of: side, to: newPlayer)
        return GameState(turn: turn, players: newPlayers, board: board)
    }
}

// MARK: - Manage GameBoard

extension GameState {
    /// 指定した位置にディスクを置いたインスタンスを返す
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: 置く位置
    func place(disk: Disk, at coordinate: Coordinate) -> GameState {
        let newBoard = board.set(disk: disk, at: coordinate)
        return GameState(turn: turn, players: players, board: newBoard)
    }

    /// 指定した位置からディスクを取り除いたインスタンスを返す
    /// - Parameter coordinate: 取り除く位置
    func removeDisk(at coordinate: Coordinate) -> GameState {
        let newBoard = board.removeDisk(at: coordinate)
        return GameState(turn: turn, players: players, board: newBoard)
    }

    func eachCells(_ body: (BoardCell) throws -> Void) rethrows {
        try board.forEach(body)
    }

    func count(of disk: Disk) -> Int {
        board.count(of: disk)
    }

    /// 指定したセルのディスクを置いたら獲得できるディスクの位置を返す
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 獲得できるディスクの位置一覧
    func coordinatesOfDisksToBeAcquired(by disk: Disk, at coordinate: Coordinate) -> [Coordinate] {
        board.coordinatesOfDisksToBeAcquired(by: disk, at: coordinate)
    }

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disk: 置くディスク
    func settableCoordinates(disk: Disk) -> [Coordinate] {
        board.settableCoordinates(disk: disk)
    }

    /// 指定したディスクを置ける位置があるかどうか判定する
    /// - Parameter disk: 置きたいディスク
    /// - Returns: 置ける位置があるならtrue
    func isSettable(disk: Disk) -> Bool {
        !board.settableCoordinates(disk: disk).isEmpty
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

// MARK: - for test

extension GameState {
    func isSameBoard(as other: GameState) -> Bool {
        board == other.board
    }

    func isSameBoard(as otherBoard: GameBoard) -> Bool {
        board == otherBoard
    }

    func disk(at coordinate: Coordinate) -> Disk? {
        board.disk(at: coordinate)
    }
}
