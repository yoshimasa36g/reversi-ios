//
//  RandomCoordinateOperation.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ディスクを置ける場所からランダムに選択するOperation
final class RandomCoordinateOperation: Operation, ComputerOperation {
    private let gameState: GameState
    private let duration: UInt32

    /// 選択した位置
    var coordinate: Coordinate?

    /// ゲームの状態を指定してインスタンスを生成する
    /// - Parameters:
    ///   - gameState: ゲームの状態
    ///   - duration: 遅延時間（秒）
    init(gameState: GameState, duration: UInt32 = 2) {
        self.gameState = gameState
        self.duration = duration
        super.init()
    }

    /// ディスクを置ける場所からランダムに位置を選択する
    /// - 選択した値を設定する前にdurationの秒数待機する
    override func main() {
        guard let turn = gameState.turn else { return }
        guard let coordinate = gameState.placeableCoordinates(disc: turn).randomElement() else {
            return
        }

        sleep(duration)

        if isCancelled { return }

        self.coordinate = coordinate
    }
}
