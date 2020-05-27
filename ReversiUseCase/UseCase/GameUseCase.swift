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
    private var isWaitPresenting = false

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

    private func changeTurn(to turn: Disc?) {
        game = game.changeTurn(to: turn)
        save()
        notifyMessage()
    }

    /// プレイヤーの行動を待ちます。
    private func waitForPlayer() {
        guard let turn = game.turn,
            let player = game.currentPlayerType else { return }

        game = game.changePlayer(of: turn, to: player.toPlayer())

        playTurn()
    }

    /// プレイヤーの行動後、そのプレイヤーのターンを終了して次のターンを開始します。
    /// もし、次のプレイヤーに有効な手が存在しない場合、パスとなります。
    /// 両プレイヤーに有効な手がない場合、ゲームの勝敗を表示します。
    private func nextTurn() {
        guard let turn = game.turn else { return }

        let next = turn.flipped

        if game.isGameOver {
            changeTurn(to: nil)
            return
        }

        changeTurn(to: next)

        if game.isPlaceable(disc: next) {
            waitForPlayer()
            return
        }

        presenter?.passed()
    }

    /// プレイヤーの行動を決定します。
    private func playTurn() {
        guard let side = game.turn else {
            preconditionFailure()
        }

        game.players.startOperation(
            gameState: game,
            onStart: { [weak self] in self?.presenter?.thinkingStarted(color: side.id) },
            onComplete: { [weak self] result in
                self?.presenter?.thinkingStopped(color: side.id)
                self?.apply(result, for: side)
            })
    }

    /// Computerの思考結果を適用する
    /// - Parameters:
    ///   - operationResult: Computerの思考結果
    ///   - side: 適用するプレイヤーのディスク
    private func apply(_ operationResult: OperationResult, for side: Disc) {
        switch operationResult {
        case .coordinate(let coordinate):
            notifyGettableCoordinates(by: coordinate)
        case .pass:
            nextTurn()
        case .cancel:
            break
        }
    }

    private func notifyGettableCoordinates(by origin: Coordinate) {
        guard let disc = game.turn else { return }

        let gettableCoordinates = game.coordinatesOfGettableDiscs(by: disc, at: origin)
        if gettableCoordinates.isEmpty { return }
        let coordinates = [origin] + gettableCoordinates
        isWaitPresenting = true
        presenter?.gettableCoordinates(color: disc.id, coordinates: coordinates.map { (x: $0.x, y: $0.y) })
    }
}

// MARK: - GameUseCaseInput

extension GameUseCase: GameUseCaseInput {
    public func startGame() {
        isWaitPresenting = false
        gateway.load()
    }

    public func resetGame() {
        isWaitPresenting = false
        changeGameState(to: game.reset())
        waitForPlayer()
    }

    public func specifyPlacingDiscCoordinate(x: Int, y: Int) {
        if game.currentPlayerType == .computer { return }

        notifyGettableCoordinates(by: Coordinate(x: x, y: y))
    }

    public func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)]) {
        isWaitPresenting = false
        let newState = game.place(disc: disc(from: color), at: coordinates.map { Coordinate(x: $0.x, y: $0.y) })
        changeGameState(to: newState)
        nextTurn()
    }

    private func disc(from color: Int) -> Disc {
        Disc(color: DiscColor(rawValue: color) ?? .dark)
    }

    public func continueGame() {
        nextTurn()
    }

    public func changePlayerType(of color: Int, to playerType: Int) {
        let side = disc(from: color)

        game.players.cancelOperation(of: side)

        let player = (PlayerType(rawValue: playerType) ?? .manual).toPlayer()
        game = game.changePlayer(of: side, to: player)
        save()

        if !isWaitPresenting, side == game.turn {
            playTurn()
        }
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
                waitForPlayer()
            case .failure(let error):
                throw error
            }
        } catch {
            resetGame()
        }
    }
}
