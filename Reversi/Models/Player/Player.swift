//
//  Player.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤーの区分
enum Player: Int, Codable {
    case manual = 0
    case computer = 1

    /// Computerの思考処理を取得する
    /// - Parameter gameState: ゲームの状態
    /// - Returns: Computerの思考処理 / manualに対して呼んだ場合はnil
    func operation(with gameState: GameState) -> ComputerOperation? {
        switch self {
        case .manual:
            return nil
        case .computer:
            return ComputerOperation(operation: RandomPositionOperation(gameState: gameState))
        }
    }

    /// Intの値からプレイヤーの区分を取得する
    /// - Parameter index: プレイヤーの区分に対応するInt値
    /// - Returns: プレイヤーの区分 / 該当する値がない場合は .manual
    static func from(index: Int) -> Player {
        Player(rawValue: index) ?? .manual
    }
}
