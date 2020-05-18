//
//  Human.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/18.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Manualのプレイヤー
struct Human: Player {
    var type: PlayerType {
        return .manual
    }

    func startOperation(onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        // 何もしない（コールバックも呼ばない）
    }

    func cancelOperation() {
        // 何もしない
    }
}
