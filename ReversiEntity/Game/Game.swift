//
//  Game.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム
public struct Game: Codable {
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

// MARK: - Manage game

extension Game: GameState {
    public var message: (disc: Disc?, label: String) {
        if let side = turn {
            return (disc: side, label: "'s turn")
        }
        if let winner = board.winner {
            return (disc: winner, label: " won")
        }
        return (disc: nil, label: "Tied")
    }

    public var currentPlayerType: PlayerType? {
        guard let disc = self.turn else {
            return nil
        }
        return players.type(of: disc)
    }

    public var isGameOver: Bool {
        board.placeableCoordinates(disc: .dark()).isEmpty
            && board.placeableCoordinates(disc: .light()).isEmpty
    }

    public func reset() -> GameState {
        Game(turn: .dark())
    }

    public func changeTurn(to newTurn: Disc?) -> GameState {
        Game(turn: newTurn, players: players, board: board)
    }

    public func changePlayer(of side: Disc, to newPlayer: Player) -> GameState {
        let newPlayers = players.changePlayer(of: side, to: newPlayer)
        return Game(turn: turn, players: newPlayers, board: board)
    }

    public func count(of disc: Disc) -> Int {
        board.count(of: disc)
    }

    public func coordinatesOfGettableDiscs(by disc: Disc, at coordinate: Coordinate) -> [Coordinate] {
        board.coordinatesOfGettableDiscs(by: disc, at: coordinate)
    }

    public func placeableCoordinates(disc: Disc) -> [Coordinate] {
        board.placeableCoordinates(disc: disc)
    }

    public func place(disc: Disc, at coordinates: [Coordinate]) -> GameState {
        let newBoard = board.place(disc, at: coordinates)
        return Game(turn: turn, players: players, board: newBoard)
    }

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
