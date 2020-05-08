//
//  GameState.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

struct GameState: Codable {
    let turn: Disk
    let players: [Player]
}
