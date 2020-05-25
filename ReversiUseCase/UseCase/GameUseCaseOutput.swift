//
//  GameUseCaseOutput.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameUseCaseからの出力プロトコル
public protocol GameUseCaseOutput: class {
    /// ゲームの状態がリセットされたか、またはロードされた時のイベント
    func gameReloaded(state: OutputGameState)
}

/// 出力用のゲームの状態
public struct OutputGameState {
    /// 現在のターンのディスクの色のID
    public let turn: Int?
    /// 黒白それぞれのプレイヤーの区分ID
    public let players: (dark: Int, light: Int)
    /// ディスクの色のIDと座標の一覧
    public let discs: [OutputDisc]
}

/// 出力用のディスク情報
public struct OutputDisc: Equatable {
    /// 色ID
    public let color: Int
    /// X座標
    public let x: Int
    /// Y座標
    public let y: Int
}
