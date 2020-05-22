//
//  GameBoardTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class GameBoardTests: XCTestCase {
    // MARK: - tests for count(of:)

    func testCountOf() {
        let board = GameBoardFactory.create(advantage: .dark)
        let darkCount = board.count(of: .dark())
        let lightCount = board.count(of: .light())
        XCTAssertEqual(darkCount, 7)
        XCTAssertEqual(lightCount, 5)
    }

    // MARK: - tests for winner()

    func testWinnerWhenDarkWins() {
        let board = GameBoardFactory.create(advantage: .dark)
        XCTAssertEqual(board.winner, .dark())
    }

    func testWinnerWhenLightWins() {
        let board = GameBoardFactory.create(advantage: .light)
        XCTAssertEqual(board.winner, .light())
    }

    func testWinnerWhenTieGame() {
        let board = GameBoardFactory.tied()
        XCTAssertNil(board.winner)
    }

    // MARK: - test for flip

    let flipTestInputs = [
        (coordinate: Coordinate(x: 4, y: 6), disc: Disc.dark()),
        (coordinate: Coordinate(x: 2, y: 6), disc: Disc.dark()),
        (coordinate: Coordinate(x: 1, y: 3), disc: Disc.light()),
        (coordinate: Coordinate(x: 4, y: 2), disc: Disc.dark()),
        (coordinate: Coordinate(x: 6, y: 2), disc: Disc.light()),
        (coordinate: Coordinate(x: 5, y: 4), disc: Disc.light()),
        (coordinate: Coordinate(x: 5, y: 4), disc: Disc.dark()),
        (coordinate: Coordinate(x: 1, y: 6), disc: Disc.dark())
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

    func testCoordinatesOfGettableDiscs() {
        zip(flipTestInputs, flipTestExpecteds).forEach { input, expected in
            let board = GameBoardFactory.create(advantage: .dark)
            let result = board.coordinatesOfGettableDiscs(by: input.disc,
                                                              at: input.coordinate)
            XCTAssertEqual(result, expected)
        }
    }

    func testIsPlaceableWhenPlaceable() {
        let board = GameBoardFactory.create(advantage: .dark)
        let result = board.isPlaceable(.dark(), at: Coordinate(x: 4, y: 6))
        XCTAssertTrue(result)
    }

    func testIsPlaceableWhenUnplaceable() {
        let board = GameBoardFactory.create(advantage: .dark)
        let result = board.isPlaceable(.dark(), at: Coordinate(x: 1, y: 6))
        XCTAssertFalse(result)
    }

    func testSettableCoordinatesWhenDarkTurn() {
        let board = GameBoardFactory.create(advantage: .dark)
        let result = board.placeableCoordinates(disc: .dark())
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
        let board = GameBoardFactory.create(advantage: .dark)
        let result = board.placeableCoordinates(disc: .light())
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

    // MARK: - test for set(disc:at:)

    // 何もない位置に置いたらBoardCellのデータが追加されること
    func testSetDiscAtEmptyCoordinate() {
        let board = gameBoardWithFewDiscs()
        let coordinate = Coordinate(x: (3..<8).randomElement() ?? 0, y: (3..<8).randomElement() ?? 0)
        let result = board.place(Disc.light(), at: coordinate)
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: coordinate))
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 0, y: 0)))
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: Coordinate(x: 1, y: 1)))
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 2, y: 2)))
        XCTAssertEqual(result.count(of: .dark()), 2)
        XCTAssertEqual(result.count(of: .light()), 2)
    }

    // ディスクがある位置に置いたらBoardCellのデータが置き換わること
    func testSetDiscAtExistsDiscCoordinate() {
        let board = gameBoardWithFewDiscs()
        let coordinate = Coordinate(x: 2, y: 2)
        let result = board.place(.light(), at: coordinate)
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 0, y: 0)))
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: Coordinate(x: 1, y: 1)))
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: Coordinate(x: 2, y: 2)))
        XCTAssertEqual(result.count(of: .dark()), 1)
        XCTAssertEqual(result.count(of: .light()), 2)
    }

    // MARK: - test for removeDisc(at:)

    // ディスクがある位置を指定したらそのデータが削除されること
    func testRemoveDiscAtExistsDiscCoordinate() {
        let board = gameBoardWithFewDiscs()
        let coordinate = Coordinate(x: 2, y: 2)
        let result = board.removeDisc(at: coordinate)
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 0, y: 0)))
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: Coordinate(x: 1, y: 1)))
        XCTAssertEqual(result.count(of: .dark()), 1)
        XCTAssertEqual(result.count(of: .light()), 1)
    }

    // 何もない位置を指定したら何も変更されないこと
    func testRemoveDiscAtEmptyCoordinate() {
        let board = gameBoardWithFewDiscs()
        let coordinate = Coordinate(x: (3..<8).randomElement() ?? 0, y: (3..<8).randomElement() ?? 0)
        let result = board.removeDisc(at: coordinate)
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 0, y: 0)))
        XCTAssertTrue(result.isDiscEquals(to: .light(), at: Coordinate(x: 1, y: 1)))
        XCTAssertTrue(result.isDiscEquals(to: .dark(), at: Coordinate(x: 2, y: 2)))
        XCTAssertEqual(result.count(of: .dark()), 2)
        XCTAssertEqual(result.count(of: .light()), 1)
    }

    private func gameBoardWithFewDiscs() -> GameBoard {
        GameBoard(cells: [
            BoardCell(coordinate: Coordinate(x: 0, y: 0), disc: .dark()),
            BoardCell(coordinate: Coordinate(x: 1, y: 1), disc: .light()),
            BoardCell(coordinate: Coordinate(x: 2, y: 2), disc: .dark())
        ])
    }
}
