//
//  GameScreenController.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiUseCase

/// 画面の入力イベントをGameUseCaseに伝える
public struct GameScreenController {
    private let useCase: GameUseCaseInput

    public init(useCase: GameUseCaseInput) {
        self.useCase = useCase
    }
}

// MARK: - GameScreenControllable

extension GameScreenController: GameScreenControllable {
    public func start() {
        useCase.startGame()
    }

    public func reset() {
        useCase.resetGame()
    }

    public func cellTapped(at coordinate: (x: Int, y: Int)) {
        useCase.specifyPlacingDiscCoordinate(x: coordinate.x, y: coordinate.y)
    }

    public func changeDiscsCompleted(color: Int, at coordinates: [(x: Int, y: Int)]) {
        useCase.changeDiscs(to: color, at: coordinates)
    }

    public func acceptPass() {
        useCase.continueGame()
    }

    public func changePlayerType(of color: Int, to playerType: Int) {
        useCase.changePlayerType(of: color, to: playerType)
    }
}
