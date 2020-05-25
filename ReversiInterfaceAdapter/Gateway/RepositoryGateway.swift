//
//  RepositoryGateway.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiUseCase

/// リポジトリのGateway
public final class RepositoryGateway {
    private let repository: GameStateRepository
    private weak var client: GameUseCaseResponse?

    /// リポジトリとクライアントを指定してインスタンスを生成する
    /// - Parameters:
    ///   - repository: ゲームの状態を保管するリポジトリ
    public init(repository: GameStateRepository) {
        self.repository = repository
    }

    /// クライアントの依存を注入する
    /// - Parameter client: 処理結果を受け取るクライアント
    public func inject(_ client: GameUseCaseResponse) {
        self.client = client
    }
}

// MARK: - GameUseCaseRequest

extension RepositoryGateway: GameUseCaseRequest {
    public func save(_ data: Data) {
        try? repository.save(data)
    }

    public func load() {
        guard let data = try? repository.load() else {
            client?.dataLoaded(result: .failure(.loadFailed))
            return
        }
        client?.dataLoaded(result: .success(data))
    }
}
