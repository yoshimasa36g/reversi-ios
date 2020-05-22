//
//  GameStateRepository.swift
//  Reversi
//
//  Created by yoshimasa36g 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation
import ReversiEntity // TODO: 後で消す
import UIKit

protocol GameStateRepository {
    func save(_ state: Game) throws
    func load() throws -> Game
}
