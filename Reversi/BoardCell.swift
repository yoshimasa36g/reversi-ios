//
//  BoardCell.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

struct BoardCell: Codable {
    let position: Position
    let disk: Disk?

    init(position: Position, disk: Disk?) {
        self.position = position
        self.disk = disk
    }

    private enum Key: CodingKey {
        case position
        case disk
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        position = try container.decode(Position.self, forKey: .position)
        disk = try? container.decode(Disk.self, forKey: .disk)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(position, forKey: .position)
        if let disk = self.disk {
            try container.encode(disk, forKey: .disk)
            return
        }
        try container.encode("-", forKey: .disk)
    }
}

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
