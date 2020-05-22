//
//  GameBoardFactory.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity

struct GameBoardFactory {
    static func create(advantage: DiscColor) -> GameBoard {
        let disadvantage = advantage.otherSide
        return GameBoard(cells: [
            BoardCell(coordinate: Coordinate(x: 2, y: 2), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 5, y: 2), disc: Disc(color: disadvantage)),
            BoardCell(coordinate: Coordinate(x: 2, y: 3), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 3, y: 3), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 4, y: 3), disc: Disc(color: disadvantage)),
            BoardCell(coordinate: Coordinate(x: 5, y: 3), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 2, y: 4), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 3, y: 4), disc: Disc(color: disadvantage)),
            BoardCell(coordinate: Coordinate(x: 4, y: 4), disc: Disc(color: advantage)),
            BoardCell(coordinate: Coordinate(x: 3, y: 5), disc: Disc(color: disadvantage)),
            BoardCell(coordinate: Coordinate(x: 4, y: 5), disc: Disc(color: disadvantage)),
            BoardCell(coordinate: Coordinate(x: 5, y: 5), disc: Disc(color: advantage))
        ])
    }

    static func tied() -> GameBoard {
        let dark = (0..<4).map { BoardCell(coordinate: Coordinate(x: $0, y: $0), disc: Disc.dark()) }
        let light = (4..<8).map { BoardCell(coordinate: Coordinate(x: $0, y: $0), disc: Disc.light()) }
        return GameBoard(cells: Set(dark + light))
    }
}
