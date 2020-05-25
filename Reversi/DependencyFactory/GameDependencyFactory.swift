//
//  GameDependencyFactory.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/25.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import ReversiInterfaceAdapter
import ReversiUseCase

struct GameDependencyFactory {
    /// 依存関係を構築してGameScreenControllerを生成する
    /// - Parameter screen: 使用する画面
    static func createGameScreenController(for screen: GameScreenPresentable) -> GameScreenControllable {
        let repository = GameStateFileStore()
        let gateway = RepositoryGateway(repository: repository)
        let presenter = GameScreenPresenter(screen: screen)
        let useCase = GameUseCase(presenter: presenter, gateway: gateway)
        gateway.inject(useCase)
        return GameScreenController(useCase: useCase)
    }
}
