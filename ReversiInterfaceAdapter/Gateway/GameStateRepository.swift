//
//  GameStateRepository.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲームの状態を保管するリポジトリのプロトコル
public protocol GameStateRepository {
    /// リポジトリにデータを格納する
    /// - Parameter data: 格納するデータ
    func save(_ data: Data) throws

    /// リポジトリからデータを読み出す
    /// - Returns: 読み出したデータ
    func load() throws -> Data
}
