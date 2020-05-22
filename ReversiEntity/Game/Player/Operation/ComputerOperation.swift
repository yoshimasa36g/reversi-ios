//
//  ComputerOperation.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// Computerの思考処理プロトコル
public protocol ComputerOperation: Operation {
    var coordinate: Coordinate? { get }
}
