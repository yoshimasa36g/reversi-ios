//
//  GameUseCaseResponse.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameUseCaseへの応答プロトコル
public protocol GameUseCaseResponse: class {
    /// データ読み込み完了時の処理
    /// - Parameter result: 処理結果（成功していれば読み込んだデータ、失敗ならエラー）
    func dataLoaded(result: Result<Data, GameUseCaseResponseError>)
}

/// GameUseCaseへの応答時のエラー
public enum GameUseCaseResponseError: Error {
    /// データ読込失敗
    case loadFailed
}
