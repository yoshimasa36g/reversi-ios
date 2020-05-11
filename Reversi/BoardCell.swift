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
    let position: Position
    /// ディスク
    let disk: Disk

    /// 位置とディスクからインスタンスを生成する
    /// - Parameters:
    ///   - position: 位置
    ///   - disk: ディスク
    init(position: Position, disk: Disk) {
        self.position = position
        self.disk = disk
    }

    /// 位置座標とディスクからインスタンスを生成する
    /// - Parameters:
    ///   - x: 位置のX座標
    ///   - y: 位置のY座標
    ///   - disk: ディスク
    init(x: Int, y: Int, disk: Disk) {
        self.position = Position(x: x, y: y)
        self.disk = disk
    }
}

// MARK: - Equatable

extension BoardCell: Equatable {
    static func == (lhs: BoardCell, rhs: BoardCell) -> Bool {
        return lhs.position == rhs.position && lhs.disk == rhs.disk
    }
}

// MARK: - Codable

extension Disk: Codable {
    private enum Key: CodingKey {
        case rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "x":
            self = .dark
        case "o":
            self = .light
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [Key.rawValue],
                      debugDescription: "Does not match any CodingKey."))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .dark:
            try container.encode("x")
        case .light:
            try container.encode("o")
        }
    }
}
