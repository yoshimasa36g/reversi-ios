//
//  Computer.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Computerのプレイヤー
final class Computer: Player {
    private var operation: ComputerOperation?
    private let queue = OperationQueue()

    var type: PlayerType {
        .computer
    }

    func startOperation(gameState: GameState, onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        let operation = RandomCoordinateOperation(gameState: gameState)
        self.operation = operation

        onStart()

        queue.addOperation(operation)

        operation.completionBlock = {
            switch (operation.coordinate, operation.isCancelled) {
            case (_, true):
                onComplete(.cancel)
            case (.none, false):
                onComplete(.pass)
            case (.some(let coordinate), false):
                onComplete(.coordinate(coordinate))
            }
        }
    }

    func cancelOperation() {
        operation?.cancel()
    }
}
