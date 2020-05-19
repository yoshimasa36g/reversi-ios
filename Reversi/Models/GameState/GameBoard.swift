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
    /// - Parameter position: ディスクを取得する位置
    /// - Returns: 指定位置のディスク/ない場合はnil
    func disk(at position: Position) -> Disk? {
        cells.first { $0.position == position }?.disk
    }

    /// 指定した位置にディスクを置いたインスタンスを返す。
    /// 既に置いてある場合は上書きする。
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - position: 置く位置
    /// - Returns: ディスクを置いたGameBoardのインスタンス
    func set(disk: Disk, at position: Position) -> GameBoard {
        let newCells = cells.filter { $0.position != position }
            + [BoardCell(position: position, disk: disk)]
        return GameBoard(cells: newCells)
    }

    /// 指定した位置のディスクを取り除いたインスタンスを返す。
    /// - Parameters:
    ///   - position: 取り除く位置
    /// - Returns: ディスクを取り除いたGameBoardのインスタンス
    func removeDisk(at position: Position) -> GameBoard {
        let newCells = cells.filter { $0.position != position }
        return GameBoard(cells: newCells)
    }

    /// 指定したセルのディスクを置いたら獲得できるディスクの位置を返す
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - position: 置く位置
    /// - Returns: 獲得できるディスクの位置一覧
    func positionsOfDisksToBeAcquired(by disk: Disk, at position: Position) -> [Position] {
        let directions = [
            Position(x: -1, y: -1),
            Position(x: 0, y: -1),
            Position(x: 1, y: -1),
            Position(x: 1, y: 0),
            Position(x: 1, y: 1),
            Position(x: 0, y: 1),
            Position(x: -1, y: 0),
            Position(x: -1, y: 1)
        ]

        guard self.disk(at: position) == nil else {
            return []
        }

        return directions.flatMap {
            reducePositionsOfDisksToBeAcquired(
                [],
                by: BoardCell(position: position, disk: disk),
                to: $0)
        }
    }

    private func reducePositionsOfDisksToBeAcquired(_ positions: [Position],
                                                    by cell: BoardCell,
                                                    to direction: Position) -> [Position] {
        let currentPosition = cell.position + direction
        let currentDisk = self.disk(at: currentPosition)
        if currentDisk == nil { return [] }
        if currentDisk == cell.disk { return positions }

        return reducePositionsOfDisksToBeAcquired(
            positions + [currentPosition],
            by: BoardCell(position: currentPosition, disk: cell.disk),
            to: direction)
    }

    /// 指定した位置にディスクを置けるか判定する
    /// - Parameters:
    ///   - disk: 置くディスク
    ///   - position: 置く位置
    /// - Returns: 置ける場合は true
    func isSettable(disk: Disk, at position: Position) -> Bool {
        !positionsOfDisksToBeAcquired(by: disk, at: position).isEmpty
    }

    private var allPositions: [Position] {
        let range = 0..<GameBoard.size
        return range.flatMap { y in range.map { x in Position(x: x, y: y) } }
    }

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disk: 置くディスク
    func settablePositions(disk: Disk) -> [Position] {
        allPositions.filter { isSettable(disk: disk, at: $0) }
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
