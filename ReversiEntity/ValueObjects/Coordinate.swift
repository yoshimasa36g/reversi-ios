//
//  Coordinate.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// 座標
public struct Coordinate: Codable, Equatable, Hashable {
    /// X座標
    public let x: Int

    /// Y座標
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// 指定した方向に隣接する座標を返す
    /// - Parameter direction: 方向
    func adjacent(to direction: Direction) -> Coordinate {
        Coordinate(x: x + direction.x,
                   y: y + direction.y)
    }
}
