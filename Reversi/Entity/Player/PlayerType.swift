//
//  PlayerType.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/14.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤーの区分
enum PlayerType: Int, Codable {
    case manual = 0
    case computer = 1

    /// プレイヤーのインスタンスに変換する
    /// - Returns: プレイヤーのインスタンス
    func toPlayer() -> Player {
        switch self {
        case .manual:
            return Human()
        case .computer:
            return Computer()
        }
    }

    /// Intの値からプレイヤーの区分を取得する
    /// - Parameter index: プレイヤーの区分に対応するInt値
    /// - Returns: プレイヤーの区分 / 該当する値がない場合は .manual
    static func from(index: Int) -> PlayerType {
        PlayerType(rawValue: index) ?? .manual
    }
}
