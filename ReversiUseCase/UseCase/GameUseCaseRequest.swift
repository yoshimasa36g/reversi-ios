//
//  GameUseCaseRequest.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameUseCaseから要求プロトコル
public protocol GameUseCaseRequest {
    /// データを保存する
    /// - Parameter data: 保存するデータ
    func save(_ data: Data)

    /// データを読み込む
    func load()
}
