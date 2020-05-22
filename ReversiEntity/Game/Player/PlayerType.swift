//
//  PlayerType.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤーの区分
public enum PlayerType: Int, Codable {
    case manual = 0
    case computer = 1

    /// プレイヤーのインスタンスに変換する
    /// - Returns: プレイヤーのインスタンス
    public func toPlayer() -> Player {
        switch self {
        case .manual:
            return Human()
        case .computer:
            return Computer { RandomCoordinateOperation(gameState: $0) }
        }
    }
}
