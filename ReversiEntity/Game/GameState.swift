//
//  GameState.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

public protocol GameState {
    var turn: Disc? { get }
    var players: Players { get }
    var board: GameBoard { get }

    /// リセットしたインスタンスを返す
    func reset() -> GameState

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disk: 置くディスク
    func placeableCoordinates(disc: Disc) -> [Coordinate]
}
