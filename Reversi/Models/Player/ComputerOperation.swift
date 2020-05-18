//
//  ComputerOperation.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/18.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// Computerの思考処理プロトコル
protocol ComputerOperation: Operation {
    var position: Position? { get }
}
