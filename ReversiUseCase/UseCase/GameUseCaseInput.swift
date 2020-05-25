//
//  GameUseCaseInput.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameUseCaseへの入力プロトコル
public protocol GameUseCaseInput {
    /// ゲームをリセットする
    func resetGame()
}
