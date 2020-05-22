//
//  Game.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム
public struct Game: GameState, Codable {
    /// ターン
    public let turn: Disc?

    /// プレイヤー情報
    public let players: Players

    /// ゲーム盤
    public let board: GameBoard

    public init(
        turn: Disc? = nil,
        players: Players = Players(darkPlayer: Human(), lightPlayer: Human()),
        board: GameBoard = GameBoard(cells: Set(GameBoard.initialCells))
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        turn = try container.decodeIfPresent(Disc.self, forKey: .turn)
        board = try container.decode(GameBoard.self, forKey: .board)
        let dark = try container.decode(PlayerType.self, forKey: .darkPlayer).toPlayer()
        let light = try container.decode(PlayerType.self, forKey: .lightPlayer).toPlayer()
        players = Players(darkPlayer: dark, lightPlayer: light)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encodeIfPresent(turn, forKey: .turn)
        try container.encode(players.type(of: .dark()), forKey: .darkPlayer)
        try container.encode(players.type(of: .light()), forKey: .lightPlayer)
        try container.encode(board, forKey: .board)
    }
}

// MARK: - Properties

extension Game {
    /// ターン表示や勝敗表示用のメッセージ
    public var message: (disc: Disc?, label: String) {
        if let side = turn {
            return (disc: side, label: "'s turn")
        }
        if let winner = board.winner {
            return (disc: winner, label: " won")
        }
        return (disc: nil, label: "Tied")
    }

    public var isGameOver: Bool {
        board.placeableCoordinates(disc: .dark()).isEmpty
            && board.placeableCoordinates(disc: .light()).isEmpty
    }
}

// MARK: - Manage game

extension Game {
    /// リセットしたインスタンスを返す
    public func reset() -> Game {
        Game(turn: .dark())
    }

    /// ターンを変更したインスタンスを返す
    /// - Parameter newTurn: 変更後のターン
    public func changeTurn(to newTurn: Disc?) -> Game {
        Game(turn: newTurn, players: players, board: board)
    }
}

// MARK: - Manage Players

extension Game {
    /// 指定した側のプレイヤーを変更したインスタンスを返す
    /// - Parameters:
    ///   - side: 変更する側
    ///   - newPlayer: 変更後のプレイヤー
    public func changePlayer(of side: Disc, to newPlayer: Player) -> Game {
        let newPlayers = players.changePlayer(of: side, to: newPlayer)
        return Game(turn: turn, players: newPlayers, board: board)
    }
}

// MARK: - Manage GameBoard

extension Game {
    /// 指定した位置にディスクを置いたインスタンスを返す
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    public func place(disc: Disc, at coordinate: Coordinate) -> Game {
        let newBoard = board.place(disc, at: coordinate)
        return Game(turn: turn, players: players, board: newBoard)
    }

    /// 指定した位置からディスクを取り除いたインスタンスを返す
    /// - Parameter coordinate: 取り除く位置
    public func removeDisc(at coordinate: Coordinate) -> Game {
        let newBoard = board.removeDisc(at: coordinate)
        return Game(turn: turn, players: players, board: newBoard)
    }

    public func count(of disc: Disc) -> Int {
        board.count(of: disc)
    }

    /// 指定したセルのディスクを置いたら獲得できるディスクの位置を返す
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 獲得できるディスクの位置一覧
    public func coordinatesOfGettableDiscs(by disc: Disc, at coordinate: Coordinate) -> [Coordinate] {
        board.coordinatesOfGettableDiscs(by: disc, at: coordinate)
    }

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disc: 置くディスク
    public func placeableCoordinates(disc: Disc) -> [Coordinate] {
        board.placeableCoordinates(disc: disc)
    }

    /// 指定したディスクを置ける位置があるかどうか判定する
    /// - Parameter disc: 置きたいディスク
    /// - Returns: 置ける位置があるならtrue
    public func isPlaceable(disc: Disc) -> Bool {
        !board.placeableCoordinates(disc: disc).isEmpty
    }
}

// MARK: - Equatable

extension Game: Equatable {
    public static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.turn == rhs.turn
            && lhs.players == rhs.players
            && lhs.board == rhs.board
    }
}
