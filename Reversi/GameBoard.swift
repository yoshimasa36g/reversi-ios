//
//  GameBoard.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲーム盤のデータを管理する
struct GameBoard: Codable, Equatable {
    /// セル一覧
    let cells: [BoardCell]

    /// 指定したディスクの枚数を取得する
    /// - Parameter disk: 枚数を取得したいディスク
    /// - Returns: 指定したディスクの枚数
    func count(of disk: Disk) -> Int {
        cells.filter({ $0.disk == disk }).count
    }

    /// 勝者のディスクを返す
    func winner() -> Disk? {
        let darkCount = count(of: .dark)
        let lightCount = count(of: .light)
        if darkCount == lightCount {
            return nil
        }
        return darkCount > lightCount ? .dark : .light
    }
}
