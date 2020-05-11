//
//  Position.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// 位置情報
struct Position: Codable, Equatable {
    /// X座標
    let x: Int

    /// Y座標
    let y: Int
}
