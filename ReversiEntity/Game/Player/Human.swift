//
//  Human.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Manualのプレイヤー
struct Human: Player {
    var type: PlayerType {
        return .manual
    }

    func startOperation(gameState: GameState, onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        // 何もしない（コールバックも呼ばない）
    }

    func cancelOperation() {
        // 何もしない
    }
}
