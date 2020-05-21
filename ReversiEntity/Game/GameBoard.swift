//
//  GameBoard.swift
//  ReversiEntity
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

/// ゲーム盤
final class GameBoard: Codable {
    private static let size = 8

    private static let range = 0..<size

    /// セル一覧
    private let cells: Set<BoardCell>

    init(cells: Set<BoardCell>) {
        self.cells = cells
    }

    /// 指定したディスクの枚数を取得する
    /// - Parameter disc: 枚数を取得したいディスク
    func count(of disc: Disc) -> Int {
        cells.filter({ $0.has(disc) }).count
    }

    /// 勝者のディスクの色
    var winner: DiscColor? {
        let darkCount = count(of: .dark())
        let lightCount = count(of: .light())
        if darkCount == lightCount {
            return nil
        }
        return darkCount > lightCount ? .dark : .light
    }

    /// 指定した位置にディスクを置いたインスタンスを返す
    /// 既に置いてある場合は上書きする。
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    func place(_ disc: Disc, at coordinate: Coordinate) -> GameBoard {
        var newCells = cells
        newCells.update(with: BoardCell(coordinate: coordinate, disc: disc))
        return GameBoard(cells: newCells)
    }

    /// 指定した位置のディスクを取り除いたインスタンスを返す
    /// - Parameters:
    ///   - coordinate: 取り除く位置
    func removeDisc(at coordinate: Coordinate) -> GameBoard {
        var newCells = cells
        newCells.remove(BoardCell(coordinate: coordinate, disc: .dark()))
        return GameBoard(cells: newCells)
    }

    /// 指定したセルにディスクを置いたら獲得できるディスクの位置をすべて返す
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    func coordinatesOfGetableDiscs(by disc: Disc, at coordinate: Coordinate) -> [Coordinate] {
        if exists(at: coordinate) { return [] }

        return Direction.allCases.reduce([]) { coordinates, direction in
            coordinates + coordinatesOfGetableDiscs(by: direction, origin: coordinate, disc: disc)
        }
    }

    /// 指定したセルにディスクを置いたら指定した方向で取得できるディスクの位置をすべて返す
    /// - Parameters:
    ///   - direction: 判定する方向
    ///   - origin: 置く位置
    ///   - disc: 置くディスク
    private func coordinatesOfGetableDiscs(
        by direction: Direction,
        origin: Coordinate,
        disc: Disc
    ) -> [Coordinate] {
        var isGetable = true
        let coordinates = sequence(first: origin) { [weak self] previous in
            let next = previous.adjacent(to: direction)
            if self?.isDiscEquals(to: disc, at: next) == true { return nil }
            if self?.isEmpty(at: next) == true {
                isGetable = false
                return nil
            }
            return next
        }.dropFirst().map { $0 }
        return isGetable ? coordinates : []
    }

    private func exists(at coordinate: Coordinate) -> Bool {
        cells.contains(BoardCell(coordinate: coordinate, disc: .dark()))
    }

    private func isEmpty(at coordinate: Coordinate) -> Bool {
        !exists(at: coordinate)
    }

    func isDiscEquals(to disc: Disc, at coordinate: Coordinate) -> Bool {
        cells.first(where: { $0.isIn(coordinate) })?.has(disc) ?? false
    }

    /// 指定した位置にディスクを置けるか判定する
    /// - Parameters:
    ///   - disc: 置くディスク
    ///   - coordinate: 置く位置
    /// - Returns: 置ける場合は true
    func isPlaceable(_ disc: Disc, at coordinate: Coordinate) -> Bool {
        !coordinatesOfGetableDiscs(by: disc, at: coordinate).isEmpty
    }

    private var allCoordinates: [Coordinate] {
        GameBoard.range.flatMap { y in GameBoard.range.map { x in Coordinate(x: x, y: y) } }
    }

    /// 指定したディスクを置ける位置を返す
    /// - Parameter disc: 置くディスク
    func placeableCoordinates(disc: Disc) -> [Coordinate] {
        allCoordinates.filter { isPlaceable(disc, at: $0) }
    }

    /// 初期状態のセル
    static var initialCells: [BoardCell] {
        [
            BoardCell(coordinate: Coordinate(x: 3, y: 3), disc: Disc.light()),
            BoardCell(coordinate: Coordinate(x: 3, y: 4), disc: Disc.dark()),
            BoardCell(coordinate: Coordinate(x: 4, y: 3), disc: Disc.dark()),
            BoardCell(coordinate: Coordinate(x: 4, y: 4), disc: Disc.light())
        ]
    }
}
