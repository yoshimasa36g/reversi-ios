//
//  BoardCell.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム盤のセル情報を管理する
struct BoardCell: Codable, Equatable {
    /// 座標
    let coordinate: Coordinate
    /// 置いてあるディスク
    let disc: Disc
}
