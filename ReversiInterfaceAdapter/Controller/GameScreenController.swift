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

}
