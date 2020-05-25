//
//  GameUseCase.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiEntity

/// ゲームを進行するUseCase
public final class GameUseCase {
    private weak var presenter: GameUseCaseOutput?
    private let gateway: GameUseCaseRequest

    private var game = Game()

    public init(presenter: GameUseCaseOutput, gateway: GameUseCaseRequest) {
        self.presenter = presenter
        self.gateway = gateway
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(game) else {
            return
        }
        gateway.save(data)
    }
}

// MARK: - GameUseCaseInput

extension GameUseCase: GameUseCaseInput {
}

// MARK: - GameUseCaseResponse

extension GameUseCase: GameUseCaseResponse {
    public func dataLoaded(result: Result<Data, GameUseCaseResponseError>) {
        do {
            switch result {
            case .success(let data):
                game = try JSONDecoder().decode(Game.self, from: data)
            case .failure(let error):
                throw error
            }
        } catch {
            game = game.reset()
        }
        save()
    }
}
