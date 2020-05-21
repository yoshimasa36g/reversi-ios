//
//  Direction.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// 盤上の方向
enum Direction: CaseIterable {
    case upperLeft
    case upper
    case upperRight
    case right
    case lowerRight
    case lower
    case lowerLeft
    case left

    /// X方向の値
    var x: Int {
        switch self {
        case .upperLeft, .left, .lowerLeft:
            return -1
        case .upper, .lower:
            return 0
        case .upperRight, .right, .lowerRight:
            return 1
        }
    }

    /// Y方向の値
    var y: Int {
        switch self {
        case .upperLeft, .upper, .upperRight:
            return -1
        case .left, .right:
            return 0
        case .lowerLeft, .lower, .lowerRight:
            return 1
        }
    }
}
