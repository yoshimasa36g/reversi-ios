//
//  Computer.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// Computerのプレイヤー
final class Computer: Player {
    private var operation: ComputerOperation?
    private let queue = OperationQueue()
    private let operationBuilder: ((GameState) -> ComputerOperation)?

    init(operationBuilder: ((GameState) -> ComputerOperation)? = nil) {
        self.operationBuilder = operationBuilder
    }

    var type: PlayerType {
        .computer
    }

    func startOperation(gameState: GameState, onStart: () -> Void, onComplete: @escaping (OperationResult) -> Void) {
        guard let operation = operationBuilder?(gameState) else {
            return
        }

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
