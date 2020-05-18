//
//  Players.swift
//  Reversi
//
//  Created by Yoshimasa Aoki on 2020/05/18.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// プレイヤー情報
struct Players {
    private let players: [Disk: Player]

    /// 黒と白それぞれのプレイヤーを指定してインスタンスを生成する
    /// - Parameters:
    ///   - darkPlayer: 黒のプレイヤー
    ///   - lightPlayer: 白のプレイヤー
    init(darkPlayer: Player, lightPlayer: Player) {
        self.players = [
            .dark: darkPlayer,
            .light: lightPlayer
        ]
    }

    /// プレイヤーを変更したインスタンスを返す
    /// - Parameters:
    ///   - side: 変更する側
    ///   - newPlayer: 新しいプレイヤー
    /// - Returns: プレイヤー変更後のインスタンス
    func changePlayer(of side: Disk, to newPlayer: Player) -> Players {
        let newPlayers = [
            side: newPlayer,
            side.flipped: players[side.flipped]
        ].compactMapValues { $0 }
        guard let dark = newPlayers[.dark], let light = newPlayers[.light] else {
            return self
        }
        return Players(darkPlayer: dark, lightPlayer: light)
    }

    /// 指定した側のプレイヤーの操作を実行する
    /// - Parameters:
    ///   - side: 操作を実行する側
    ///   - onStart: 操作開始時の処理
    ///   - onComplete: 操作完了時の処理
    func startOperation(of side: Disk,
                        onStart: @escaping () -> Void,
                        onComplete: @escaping (OperationResult) -> Void) {
        players[side]?.startOperation(onStart: onStart, onComplete: onComplete)
    }

    /// 指定した側のプレイヤーの操作をキャンセルする
    /// - Parameter side: 操作をキャンセルする側
    func cancelOperation(of side: Disk) {
        players[side]?.cancelOperation()
    }

    /// すべてのプレイヤーの操作をキャンセルする
    func cancelAll() {
        players.values.forEach { $0.cancelOperation() }
    }
}
