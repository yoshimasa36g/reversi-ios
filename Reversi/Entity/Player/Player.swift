//
//  Player.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/18.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤーのプロトコル
protocol Player {
    /// プレイヤー区分
    var type: PlayerType { get }

    /// 操作を開始する
    /// - Parameters:
    ///   - gameState: ゲームの状態
    ///   - onStart: 開始時に行う処理
    ///   - onComplete: 終了時に行う処理
    func startOperation(gameState: GameState, onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void)

    /// 操作を中断する
    func cancelOperation()
}

/// 操作結果
enum OperationResult {
    /// 位置を選択した
    case coordinate(Coordinate)
    /// 選択できる位置がなかったのでパスした
    case pass
    /// キャンセルされた
    case cancel
}
