//
//  GameBoardTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/11.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class GameBoardTests: XCTestCase {

    // MARK: - tests for count(of:)

    func testCountOf() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let darkCount = board.count(of: .dark)
        let lightCount = board.count(of: .light)
        XCTAssertEqual(darkCount, 7)
        XCTAssertEqual(lightCount, 5)
    }

    // MARK: - tests for winner()

    func testWinnerWhenDarkWins() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        XCTAssertEqual(board.winner(), .dark)
    }

    func testWinnerWhenLightWins() {
        let board = ModelsHelper.createGameBoard(advantage: .light)
        XCTAssertEqual(board.winner(), .light)
    }

    func testWinnerWhenTieGame() {
        let board = ModelsHelper.createTieGameBoard()
        XCTAssertNil(board.winner())
    }

    // MARK: - test for filp

    let flipTestInputs: [BoardCell] = [
        BoardCell(x: 4, y: 6, disk: .dark),
        BoardCell(x: 2, y: 6, disk: .dark),
        BoardCell(x: 1, y: 3, disk: .light),
        BoardCell(x: 4, y: 2, disk: .dark),
        BoardCell(x: 6, y: 2, disk: .light),
        BoardCell(x: 5, y: 4, disk: .light),
        BoardCell(x: 5, y: 4, disk: .dark),
        BoardCell(x: 1, y: 6, disk: .dark)
    ]

    let flipTestExpecteds: [[Coordinate]] = [
        [Coordinate(x: 3, y: 5), Coordinate(x: 4, y: 5)],
        [Coordinate(x: 3, y: 5)],
        [Coordinate(x: 2, y: 3), Coordinate(x: 3, y: 3), Coordinate(x: 2, y: 4)],
        [Coordinate(x: 4, y: 3)],
        [Coordinate(x: 5, y: 3), Coordinate(x: 4, y: 4)],
        [Coordinate(x: 5, y: 3), Coordinate(x: 4, y: 4)],
        [],
        []
    ]

    func testCoordinatesOfDisksToBeAcquired() {
        zip(flipTestInputs, flipTestExpecteds).forEach { input, expected in
            let board = ModelsHelper.createGameBoard(advantage: .dark)
            let result = board.coordinatesOfDisksToBeAcquired(by: input.disk,
                                                              at: input.coordinate)
            XCTAssertEqual(result, expected)
        }
    }

    func testIsSettableWhenSettable() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.isSettable(disk: .dark, at: Coordinate(x: 4, y: 6))
        XCTAssertTrue(result)
    }

    func testIsSettableWhenUnsettable() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.isSettable(disk: .dark, at: Coordinate(x: 1, y: 6))
        XCTAssertFalse(result)
    }

    func testSettableCoordinatesWhenDarkTurn() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.settableCoordinates(disk: .dark)
        let expected = [
            Coordinate(x: 5, y: 1),
            Coordinate(x: 4, y: 2),
            Coordinate(x: 2, y: 5),
            Coordinate(x: 2, y: 6),
            Coordinate(x: 3, y: 6),
            Coordinate(x: 4, y: 6),
            Coordinate(x: 5, y: 6)
        ]
        XCTAssertEqual(result, expected)
    }

    func testSettableCoordinatesWhenLightTurn() {
        let board = ModelsHelper.createGameBoard(advantage: .dark)
        let result = board.settableCoordinates(disk: .light)
        let expected = [
            Coordinate(x: 1, y: 2),
            Coordinate(x: 3, y: 2),
            Coordinate(x: 6, y: 2),
            Coordinate(x: 1, y: 3),
            Coordinate(x: 6, y: 3),
            Coordinate(x: 1, y: 4),
            Coordinate(x: 5, y: 4),
            Coordinate(x: 6, y: 5)
        ]
        XCTAssertEqual(result, expected)
    }

    // MARK: - test for set(disk:at:)

    // 何もない位置に置いたらBoardCellのデータが追加されること
    func testSetDiskAtEmptyCoordinate() {
        let board = gameBoardWithFewDisks()
        let coordinate = Coordinate(x: (3..<8).randomElement() ?? 0, y: (3..<8).randomElement() ?? 0)
        let result = board.set(disk: .light, at: coordinate)
        XCTAssertEqual(result.disk(at: coordinate), .light)
        XCTAssertEqual(result.disk(at: Coordinate(x: 0, y: 0)), .dark)
        XCTAssertEqual(result.disk(at: Coordinate(x: 1, y: 1)), .light)
        XCTAssertEqual(result.disk(at: Coordinate(x: 2, y: 2)), .dark)
        XCTAssertEqual(result.count(of: .dark), 2)
        XCTAssertEqual(result.count(of: .light), 2)
    }

    // ディスクがある位置に置いたらBoardCellのデータが置き換わること
    func testSetDiskAtExistsDiskCoordinate() {
        let board = gameBoardWithFewDisks()
        let coordinate = Coordinate(x: 2, y: 2)
        let result = board.set(disk: .light, at: coordinate)
        XCTAssertEqual(result.disk(at: Coordinate(x: 0, y: 0)), .dark)
        XCTAssertEqual(result.disk(at: Coordinate(x: 1, y: 1)), .light)
        XCTAssertEqual(result.disk(at: Coordinate(x: 2, y: 2)), .light)
        XCTAssertEqual(result.count(of: .dark), 1)
        XCTAssertEqual(result.count(of: .light), 2)
    }

    // MARK: - test for removeDisk(at:)

    // ディスクがある位置を指定したらそのデータが削除されること
    func testRemoveDiskAtExistsDiskCoordinate() {
        let board = gameBoardWithFewDisks()
        let coordinate = Coordinate(x: 2, y: 2)
        let result = board.removeDisk(at: coordinate)
        XCTAssertEqual(result.disk(at: Coordinate(x: 0, y: 0)), .dark)
        XCTAssertEqual(result.disk(at: Coordinate(x: 1, y: 1)), .light)
        XCTAssertEqual(result.count(of: .dark), 1)
        XCTAssertEqual(result.count(of: .light), 1)
    }

    // 何もない位置を指定したら何も変更されないこと
    func testRemoveDiskAtEmptyCoordinate() {
        let board = gameBoardWithFewDisks()
        let coordinate = Coordinate(x: (3..<8).randomElement() ?? 0, y: (3..<8).randomElement() ?? 0)
        let result = board.removeDisk(at: coordinate)
        XCTAssertEqual(result.disk(at: Coordinate(x: 0, y: 0)), .dark)
        XCTAssertEqual(result.disk(at: Coordinate(x: 1, y: 1)), .light)
        XCTAssertEqual(result.disk(at: Coordinate(x: 2, y: 2)), .dark)
        XCTAssertEqual(result.count(of: .dark), 2)
        XCTAssertEqual(result.count(of: .light), 1)
    }

    private func gameBoardWithFewDisks() -> GameBoard {
        GameBoard(cells: [
            BoardCell(x: 0, y: 0, disk: .dark),
            BoardCell(x: 1, y: 1, disk: .light),
            BoardCell(x: 2, y: 2, disk: .dark)
        ])
    }
}
