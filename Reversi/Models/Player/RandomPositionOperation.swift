//
//  RandomPositionOperation.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ディスクを置ける場所からランダムに選択するOperation
final class RandomPositionOperation: Operation {
    private let gameState: GameState

    /// 選択した位置
    var position: Position?

    /// ゲームの状態を指定してインスタンスを生成する
    /// - Parameter gameState: ゲームの状態
    init(gameState: GameState) {
        self.gameState = gameState
        super.init()
    }

    /// ディスクを置ける場所からランダムに位置を選択する
    /// - 選択した値を設定する前に2秒待機する
    override func main() {
        guard let turn = gameState.turn else { return }
        guard let position = gameState.board.settablePositions(disk: turn).randomElement() else {
            return
        }

        sleep(2)

        if isCancelled { return }

        self.position = position
    }
}
