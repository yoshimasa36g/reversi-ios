//
//  Player.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤーのプロトコル
public protocol Player {
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
