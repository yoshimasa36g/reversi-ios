//
//  Coordinate.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// 座標
public struct Coordinate: Codable, Equatable {
    /// X座標
    public let x: Int

    /// Y座標
    public let y: Int

    /// 別のインスタンスのX座標とY座標をそれぞれ加算した座標を返す
    /// - Parameter other: 加算する座標
    public func add(_ other: Coordinate) -> Coordinate {
        Coordinate(x: x + other.x, y: y + other.y)
    }
}
