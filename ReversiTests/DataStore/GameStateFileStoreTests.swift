@testable import Reversi
import ReversiEntity
import XCTest

final class GameStateFileStoreTests: XCTestCase {
    private let subject = GameStateFileStore(fileName: "GameStateForTest")

    private var validGame: Game {
        let turn: Disc = .dark()
        let board = GameBoard(cells: [
            BoardCell(coordinate: Coordinate(x: 0, y: 0), disc: .dark()),
            BoardCell(coordinate: Coordinate(x: 2, y: 0), disc: .dark()),
            BoardCell(coordinate: Coordinate(x: 4, y: 0), disc: .light()),
            BoardCell(coordinate: Coordinate(x: 1, y: 1), disc: .dark()),
            BoardCell(coordinate: Coordinate(x: 2, y: 1), disc: .light()),
            BoardCell(coordinate: Coordinate(x: 3, y: 1), disc: .light()),
            BoardCell(coordinate: Coordinate(x: 4, y: 1), disc: .light()),
            BoardCell(coordinate: Coordinate(x: 5, y: 1), disc: .light())
        ])
        return Game(turn: turn, players: Players(darkPlayer: Human(), lightPlayer: Computer()), board: board)
    }

    func testSaveAndLoad() {
        try? subject.save(validGame)
        let savedGame = try? subject.load()
        XCTAssertEqual(savedGame, validGame)
    }
}
