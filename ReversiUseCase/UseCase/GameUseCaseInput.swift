//
//  GameUseCaseInput.swift
//  ReversiUseCase
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameUseCaseへの入力プロトコル
public protocol GameUseCaseInput {
    /// ゲームを開始する
    func startGame()

    /// ゲームをリセットする
    func resetGame()

    /// ディスクを置きたい座標を指定する
    /// - Parameters:
    ///   - x: X座標
    ///   - y: Y座標
    func specifyPlacingDiscCoordinate(x: Int, y: Int)

    /// 指定した位置のディスクを指定した色に変更する
    /// - Parameters:
    ///   - color: ディスクの色ID
    ///   - coordinates: 変更したい座標一覧
    func changeDiscs(to color: Int, at coordinates: [(x: Int, y: Int)])

    /// ゲームを続ける
    func continueGame()

    /// プレイヤーの区分を変更する
    /// - Parameters:
    ///   - color: 変更するプレイヤーのディスクの色ID
    ///   - playerType: 変更後のぷれいやー区分ID
    func changePlayerType(of color: Int, to playerType: Int)
}
