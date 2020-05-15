//
//  ModelsHelper.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/15.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi

struct ModelsHelper {
    static func createGameBoard(advantage: Disk) -> GameBoard {
        let disadvantage: Disk = advantage == .dark ? .light : .dark
        return GameBoard(cells: [
            BoardCell(x: 2, y: 2, disk: advantage),
            BoardCell(x: 5, y: 2, disk: disadvantage),
            BoardCell(x: 2, y: 3, disk: advantage),
            BoardCell(x: 3, y: 3, disk: advantage),
            BoardCell(x: 4, y: 3, disk: disadvantage),
            BoardCell(x: 5, y: 3, disk: advantage),
            BoardCell(x: 2, y: 4, disk: advantage),
            BoardCell(x: 3, y: 4, disk: disadvantage),
            BoardCell(x: 4, y: 4, disk: advantage),
            BoardCell(x: 3, y: 5, disk: disadvantage),
            BoardCell(x: 4, y: 5, disk: disadvantage),
            BoardCell(x: 5, y: 5, disk: advantage)
        ])
    }

    static func createTieGameBoard() -> GameBoard {
        let dark = (0..<5).map { BoardCell(x: $0, y: $0, disk: .dark) }
        let light = (0..<5).map { BoardCell(x: $0, y: $0, disk: .light) }
        return GameBoard(cells: dark + light)
    }
}
