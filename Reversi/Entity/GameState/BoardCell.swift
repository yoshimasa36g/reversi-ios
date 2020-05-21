//
//  BoardCell.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲーム盤のセル情報を管理する
struct BoardCell: Codable {
    /// 位置
    let coordinate: Coordinate
    /// ディスク
    let disk: Disk

    /// 位置とディスクからインスタンスを生成する
    /// - Parameters:
    ///   - coordinate: 位置
    ///   - disk: ディスク
    init(coordinate: Coordinate, disk: Disk) {
        self.coordinate = coordinate
        self.disk = disk
    }

    /// 位置座標とディスクからインスタンスを生成する
    /// - Parameters:
    ///   - x: 位置のX座標
    ///   - y: 位置のY座標
    ///   - disk: ディスク
    init(x: Int, y: Int, disk: Disk) {
        self.coordinate = Coordinate(x: x, y: y)
        self.disk = disk
    }
}

// MARK: - Equatable

extension BoardCell: Equatable {
    static func == (lhs: BoardCell, rhs: BoardCell) -> Bool {
        return lhs.coordinate == rhs.coordinate && lhs.disk == rhs.disk
    }
}