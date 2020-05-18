//
//  Computer.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Computerのプレイヤー
struct Computer: Player {
    private let operation: ComputerOperation?
    private let queue = OperationQueue()

    /// Operationを指定してインスタンスを生成する
    /// - Parameter operation: 思考処理のOperation
    init(operation: ComputerOperation?) {
        self.operation = operation
    }

    var type: PlayerType {
        .computer
    }

    func startOperation(onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        guard let operation = self.operation, !operation.isFinished else {
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

    func cancelOperation() {
        operation?.cancel()
    }
}
