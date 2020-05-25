//
//  GameScreenPresenter.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiUseCase

/// GameUseCaseの出力結果を表示用に加工する
public final class GameScreenPresenter {
    private weak var screen: GameScreenPresentable?

    public init(screen: GameScreenPresentable) {
        self.screen = screen
    }
}

// MARK: - GameUseCaseOutput

extension GameScreenPresenter: GameUseCaseOutput {
    public func gameReloaded(state: OutputGameState) {
        screen?.redrawEntireGame(state: PresentableGameState.from(state))
    }

    public func messageChanged(color: Int?, label: String) {
        screen?.redrawMessage(color: color, label: label)
    }

    public func discCountChanged(dark: Int, light: Int) {
        screen?.redrawDiscCount(dark: dark, light: light)
    }
}
