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

    /// ターン表示や勝敗表示用のメッセージ
    var message: (disc: Disc?, label: String) { get }

    /// 現在のターンのプレイヤーの区分
    var currentPlayerType: PlayerType? { get }

    /// ゲーム終了か
    var isGameOver: Bool { get }

    /// 指定したディスクの枚数を返す
    /// - Parameter disc: 枚数を取得したいディスク
    func count(of disc: Disc) -> Int

    /// リセットしたインスタンスを返す
    func reset() -> GameState

    /// ターンを変更したインスタンスを返す
    /// - Parameter newTurn: 変更後のターン
    func changeTurn(to newTurn: Disc?) -> GameState

    /// 指定した側のプレイヤーを変更したインスタンスを返す
    /// - Parameters:
    ///   - side: 変更する側
    ///   - newPlayer: 変更後のプレイヤー
    func changePlayer(of side: Disc, to newPlayer: Player) -> GameState

    /// 指定したセルのディスクを置いたら獲得できるディスクの位置を返す
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 獲得できるディスクの位置一覧
    func coordinatesOfGettableDiscs(by disc: Disc, at coordinate: Coordinate) -> [Coordinate]

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disk: 置くディスク
    func placeableCoordinates(disc: Disc) -> [Coordinate]

    /// 指定した位置にディスクを置いたインスタンスを返す
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinates: 置く座標の一覧
    func place(disc: Disc, at coordinates: [Coordinate]) -> GameState

    /// 指定したディスクを置ける位置があるかどうか判定する
    /// - Parameter disc: 置きたいディスク
    /// - Returns: 置ける位置があるならtrue
    func isPlaceable(disc: Disc) -> Bool
}
