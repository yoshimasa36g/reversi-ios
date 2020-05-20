//
//  GameBoard.swift
//  Reversi
//
//  Created by yoshimasa36g on 2020/05/08.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

import Foundation

/// ゲーム盤のデータを管理する
struct GameBoard: Codable, Equatable {
    private static let size = 8

    /// セル一覧
    private let cells: [BoardCell]

    init(cells: [BoardCell]) {
        self.cells = cells
    }

    func forEach(_ body: (BoardCell) throws -> Void) rethrows {
        try cells.forEach(body)
    }

    /// 指定したディスクの枚数を取得する
    /// - Parameter disk: 枚数を取得したいディスク
    /// - Returns: 指定したディスクの枚数
    func count(of disk: Disk) -> Int {
        cells.filter({ $0.disk == disk }).count
    }

    /// 勝者のディスクを返す
    func winner() -> Disk? {
        let darkCount = count(of: .dark)
        let lightCount = count(of: .light)
        if darkCount == lightCount {
            return nil
        }
        return darkCount > lightCount ? .dark : .light
    }

    /// 指定した位置のディスクを返す
    /// - Parameter coordinate: ディスクを取得する位置
    /// - Returns: 指定位置のディスク/ない場合はnil
    func disk(at coordinate: Coordinate) -> Disk? {
        cells.first { $0.coordinate == coordinate }?.disk
    }

    /// 指定した位置にディスクを置いたインスタンスを返す。
    /// 既に置いてある場合は上書きする。
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: ディスクを置いたGameBoardのインスタンス
    func set(disk: Disk, at coordinate: Coordinate) -> GameBoard {
        let newCells = cells.filter { $0.coordinate != coordinate }
            + [BoardCell(coordinate: coordinate, disk: disk)]
        return GameBoard(cells: newCells)
    }

    /// 指定した位置のディスクを取り除いたインスタンスを返す。
    /// - Parameters:
    ///   - coordinate: 取り除く位置
    /// - Returns: ディスクを取り除いたGameBoardのインスタンス
    func removeDisk(at coordinate: Coordinate) -> GameBoard {
        let newCells = cells.filter { $0.coordinate != coordinate }
        return GameBoard(cells: newCells)
    }

    /// 指定したセルのディスクを置いたら獲得できるディスクの位置を返す
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 獲得できるディスクの位置一覧
    func coordinatesOfDisksToBeAcquired(by disk: Disk, at coordinate: Coordinate) -> [Coordinate] {
        let directions = [
            Coordinate(x: -1, y: -1),
            Coordinate(x: 0, y: -1),
            Coordinate(x: 1, y: -1),
            Coordinate(x: 1, y: 0),
            Coordinate(x: 1, y: 1),
            Coordinate(x: 0, y: 1),
            Coordinate(x: -1, y: 0),
            Coordinate(x: -1, y: 1)
        ]

        guard self.disk(at: coordinate) == nil else {
            return []
        }

        return directions.flatMap {
            reduceCoordinatesOfDisksToBeAcquired(
                [],
                by: BoardCell(coordinate: coordinate, disk: disk),
                to: $0)
        }
    }

    private func reduceCoordinatesOfDisksToBeAcquired(_ coordinates: [Coordinate],
                                                      by cell: BoardCell,
                                                      to direction: Coordinate) -> [Coordinate] {
        let currentCoordinate = cell.coordinate + direction
        let currentDisk = self.disk(at: currentCoordinate)
        if currentDisk == nil { return [] }
        if currentDisk == cell.disk { return coordinates }

        return reduceCoordinatesOfDisksToBeAcquired(
            coordinates + [currentCoordinate],
            by: BoardCell(coordinate: currentCoordinate, disk: cell.disk),
            to: direction)
    }

    /// 指定した位置にディスクを置けるか判定する
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 置ける場合は true
    func isSettable(disk: Disk, at coordinate: Coordinate) -> Bool {
        !coordinatesOfDisksToBeAcquired(by: disk, at: coordinate).isEmpty
    }

    private var allCoordinates: [Coordinate] {
        let range = 0..<GameBoard.size
        return range.flatMap { y in range.map { x in Coordinate(x: x, y: y) } }
    }

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disk: 置くディスク
    func settableCoordinates(disk: Disk) -> [Coordinate] {
        allCoordinates.filter { isSettable(disk: disk, at: $0) }
    }

    /// 初期状態のセル
    static var initialCells: [BoardCell] {
        [
            BoardCell(x: 3, y: 3, disk: .light),
            BoardCell(x: 3, y: 4, disk: .dark),
            BoardCell(x: 4, y: 3, disk: .dark),
            BoardCell(x: 4, y: 4, disk: .light)
        ]
    }
}
