//
//  Disc.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム盤に置くディスク
/// - 元のコードでは `Disk` 表記だったが、Wikipedia等で確認すると `Disc` が正しそう
public struct Disc: Codable, Equatable {
    public let color: DiscColor

    public var flipped: Disc {
        Disc(color: color.otherSide)
    }

    public static func dark() -> Disc {
        Disc(color: .dark)
    }

    public static func light() -> Disc {
        Disc(color: .light)
    }
}
