//
//  Disc.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム盤に置くディスク
/// - 元のコードでは `Disk` 表記だったが、Wikipedia等で確認すると `Disc` が正しそう
public struct Disc: Codable, Equatable, Hashable {
    /// 表の色
    private let color: DiscColor

    /// 面の色を指定してインスタンスを生成する
    /// - Parameter color: 表の色
    public init(color: DiscColor) {
        self.color = color
    }

    /// 反転したディスク
    public var flipped: Disc {
        Disc(color: color.otherSide)
    }

    /// 黒が表のディスクを生成する
    public static func dark() -> Disc {
        Disc(color: .dark)
    }

    /// 白が表のディスクを生成する
    public static func light() -> Disc {
        Disc(color: .light)
    }
}
