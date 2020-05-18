//
//  Computer.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Computer
final class Computer {
    private let operation: ComputerOperation?
    private let queue = OperationQueue()

    /// Operationを指定してインスタンスを生成する
    /// - Parameter operation: 思考処理のOperation
    init(operation: ComputerOperation?) {
        self.operation = operation
    }

    /// Computerの思考処理を開始する
    /// - Parameters:
    ///   - onStart: 開始時に行う処理
    ///   - onComplete: 終了時に行う処理
    func startOperation(onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        guard let operation = self.operation else {
            return
        }

        onStart()

        queue.addOperation(operation)

        operation.completionBlock = {
            switch (operation.position, operation.isCancelled) {
            case (_, true):
                onComplete(.cancel)
            case (.none, false):
                onComplete(.noPosition)
            case (.some(let position), false):
                onComplete(.position(position))
            }
        }
    }

    /// 思考処理をキャンセルする
    func cancelOperation() {
        operation?.cancel()
    }
}

/// Computerの思考処理結果
enum OperationResult {
    /// 位置を選択した
    case position(Position)
    /// 選択できる位置がなかった
    case noPosition
    /// キャンセルされた
    case cancel
}
