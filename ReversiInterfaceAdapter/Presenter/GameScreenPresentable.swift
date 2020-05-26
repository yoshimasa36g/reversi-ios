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

    /// メッセージを再描画する
    /// - Parameters:
    ///   - color: ディスクの色ID
    ///   - label: ラベル
    func redrawMessage(color: Int?, label: String)

    /// ディスク枚数を再描画する
    /// - Parameters:
    ///   - dark: 黒の数
    ///   - light: 白の数
    func redrawDiscCount(dark: Int, light: Int)

    /// 指定した座標のディスク指定した色に変える
    /// - Parameters:
    ///   - color: ディスクの色ID
    ///   - coordinates: ディスクの座標一覧
    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)])

    /// パスしたメッセージを表示する
    func showPassedMessage()

    /// インジケータを表示する
    /// - Parameter color: ディスクの色ID
    func showIndicator(for color: Int)

    /// インジケータを隠す
    /// - Parameter color: ディスクの色ID
    func hideIndicator(for color: Int)
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
