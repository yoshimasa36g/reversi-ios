//
//  RepositoryGateway.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiUseCase

/// リポジトリのGateway
public struct RepositoryGateway {
    private weak var client: GameUseCaseResponse?

    init(client: GameUseCaseResponse) {
        self.client = client
    }
}

// MARK: - GameUseCaseRequest

extension RepositoryGateway: GameUseCaseRequest {

}
