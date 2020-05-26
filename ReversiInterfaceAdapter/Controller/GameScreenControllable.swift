//
//  GameScreenControllable.swift
//  ReversiInterfaceAdapter
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// GameScreenControllerに入力するプロトコル
public protocol GameScreenControllable {
    /// ゲームを開始する
    func start()

    /// ゲームをリセットする
    func reset()

    /// ディスクを置きたい座標を指定する
    /// - Parameters:
    ///   - x: X座標
    ///   - y: Y座標
    func specifyPlacingDiscCoordinate(x: Int, y: Int)

    /// ディスクの変更描画が完了した
    /// - Parameters:
    ///   - color: ディスクの色ID
    ///   - coordinates: 変更した位置の座標一覧
    func changeDiscsCompleted(color: Int, at coordinates: [(x: Int, y: Int)])

    /// パスを受け入れる
    func acceptPass()

    /// プレイヤーの区分を変更する
    /// - Parameters:
    ///   - color: 変更するプレイヤーのディスクの色ID
    ///   - playerType: 変更後のぷれいやー区分ID
    func changePlayerType(of color: Int, to playerType: Int)
}
