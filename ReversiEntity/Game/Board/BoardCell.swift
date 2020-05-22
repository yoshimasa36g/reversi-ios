//
//  BoardCell.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム盤のセル情報を管理する
struct BoardCell: Codable {
    /// 座標
    private let coordinate: Coordinate
    /// 置いてあるディスク
    private let disc: Disc

    init(coordinate: Coordinate, disc: Disc) {
        self.coordinate = coordinate
        self.disc = disc
    }

    /// 指定したディスクを持っているか
    /// - Parameter disc: 検証するディスク
    /// - Returns: 持っているならtrue
    func has(_ disc: Disc) -> Bool {
        self.disc == disc
    }

    /// 指定した座標にあるか
    /// - Parameter coordinate: 座標
    /// - Returns: 指定した座標にある場合はtrue
    func isIn(_ coordinate: Coordinate) -> Bool {
        self.coordinate == coordinate
    }
}

// MARK: - Hashable

extension BoardCell: Hashable {
    // 座標が同じなら同じセルとする
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate)
    }
}

// MARK: - Equatable

extension BoardCell: Equatable {
    // 座標が同じなら同じセルとする
    static func == (lhs: BoardCell, rhs: BoardCell) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}
