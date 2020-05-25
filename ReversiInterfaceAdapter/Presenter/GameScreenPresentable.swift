//
//  GameScreenPresentable.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiUseCase

/// GameScreenPresenterの出力を受け取るプロトコル
public protocol GameScreenPresentable: class {
    /// ゲーム全体を再描画する
    /// - Parameter state: ゲームの状態
    func redrawEntireGame(state: PresentableGameState)
}

/// 出力用のゲームの状態
public struct PresentableGameState {
    /// 現在のターンのディスクの色のID
    public let turn: Int?
    /// 黒白それぞれのプレイヤーの区分ID
    public let players: (dark: Int, light: Int)
    /// ディスクの色のIDと座標の一覧
    public let discs: [PresentableDisc]

    static func from(_ output: OutputGameState) -> PresentableGameState {
        PresentableGameState(turn: output.turn,
                             players: output.players,
                             discs: output.discs.map { PresentableDisc.from($0) })
    }
}

/// 出力用のディスク情報
public struct PresentableDisc: Equatable {
    /// 色ID
    public let color: Int
    /// X座標
    public let x: Int
    /// Y座標
    public let y: Int

    static func from(_ output: OutputDisc) -> PresentableDisc {
        PresentableDisc(color: output.color, x: output.x, y: output.y)
    }
}
