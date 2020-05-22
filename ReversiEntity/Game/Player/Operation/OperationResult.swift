//
//  OperationResult.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// 操作結果
enum OperationResult {
    /// 位置を選択した
    case coordinate(Coordinate)
    /// 選択できる位置がなかったのでパスした
    case pass
    /// キャンセルされた
    case cancel
}
