//
//  GameUseCase.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲームを進行するUseCase
public final class GameUseCase {
    private weak var presenter: GameUseCaseOutput?

    public init(presenter: GameUseCaseOutput) {
        self.presenter = presenter
    }
}

// MARK: - GameUseCaseInput

extension GameUseCase: GameUseCaseInput {

}

// MARK: - GameUseCaseResponse

extension GameUseCase: GameUseCaseResponse {

}
