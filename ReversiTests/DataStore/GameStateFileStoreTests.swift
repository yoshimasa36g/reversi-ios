@testable import Reversi
import XCTest

final class GameStateFileStoreTests: XCTestCase {
    private let subject = GameStateFileStore(fileName: "GameStateForTest")

    private func sampleData() -> Data {
        return UUID().uuidString.data(using: .utf8) ?? Data()
    }

    func testSaveAndLoad() {
        let data = sampleData()
        try? subject.save(data)
        let savedGame = try? subject.load()
        XCTAssertEqual(savedGame, data)
    }
}
