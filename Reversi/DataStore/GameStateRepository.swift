//
//  GameStateRepository.swift
//  Reversi
//
//  Created by yoshimasa36g 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation
import UIKit

protocol GameStateRepository {
    func save(turn: Disk?, playerControls: [UISegmentedControl], boardView: BoardView) throws
    func load(playerControls: [UISegmentedControl], boardView: BoardView, completion: (Disk?) -> Void) throws
}
