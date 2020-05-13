//
//  DiskExtensions.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/13.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

extension Disk: Codable {
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
                .init(codingPath: [],
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
