//
//  DiscColor.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ディスクの色
public enum DiscColor: Int, Codable {
    /// 黒
    case dark = 0
    /// 白
    case light = 1

    /// 反対側の色
    var otherSide: DiscColor {
        switch self {
        case .dark: return .light
        case .light: return .dark
        }
    }
}
