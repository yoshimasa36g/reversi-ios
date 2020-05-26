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
    private let presenter: GameUseCaseOutput?
    private let gateway: GameUseCaseRequest

    private var game: GameState = Game()

    /// 出力先とデータ保存のリクエスト先を指定してインスタンスを生成する
    /// - Parameters:
    ///   - presenter: 処理結果の出力先
    ///   - gateway: データ保存のリクエスト先
    public init(presenter: GameUseCaseOutput, gateway: GameUseCaseRequest) {
        self.presenter = presenter
        self.gateway = gateway
    }

    private func save() {
        guard let game = self.game as? Game,
            let data = try? JSONEncoder().encode(game) else {
            return
        }
        gateway.save(data)
    }

    private func outputState() -> OutputGameState {
        let discs = game.board.map { cell in
            OutputDisc(color: cell.disc.id, x: cell.coordinate.x, y: cell.coordinate.y)
        }
        return OutputGameState(turn: game.turn?.id,
                               players: (dark: game.players.id(of: .dark()), light: game.players.id(of: .light())),
                               discs: discs)
    }

    private func changeGameState(to state: GameState) {
        game.players.cancelAll()
        game = state
        save()
        presenter?.gameReloaded(state: outputState())
        notifyMessage()
        notifyDiscCount()
    }

    private func notifyMessage() {
        let message = game.message
        presenter?.messageChanged(color: message.disc?.id, label: message.label)
    }

    private func notifyDiscCount() {
        presenter?.discCountChanged(dark: game.count(of: .dark()), light: game.count(of: .light()))
    }
}

// MARK: - GameUseCaseInput

extension GameUseCase: GameUseCaseInput {
    public func startGame() {
        gateway.load()
    }

    public func resetGame() {
        changeGameState(to: game.reset())
    }
}

// MARK: - GameUseCaseResponse

extension GameUseCase: GameUseCaseResponse {
    public func dataLoaded(result: Result<Data, GameUseCaseResponseError>) {
        do {
            switch result {
            case .success(let data):
                let state: GameState = try JSONDecoder().decode(Game.self, from: data)
                changeGameState(to: state)
            case .failure(let error):
                throw error
            }
        } catch {
            resetGame()
        }
    }
}
