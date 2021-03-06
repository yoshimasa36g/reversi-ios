//
//  Human.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Manualのプレイヤー
public struct Human: Player {
    public init() {}

    public var type: PlayerType {

        return .manual
    }

    public func startOperation(
        gameState: GameState,
        onStart: () -> Void,
        onComplete: @escaping (OperationResult) -> Void
    ) {
        // 何もしない（コールバックも呼ばない）
    }

    public func cancelOperation() {
        // 何もしない
    }
}
