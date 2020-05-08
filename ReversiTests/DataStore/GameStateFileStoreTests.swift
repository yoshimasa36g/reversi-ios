@testable import Reversi
import XCTest

final class GameStateFileStoreTest: XCTestCase {

    private var viewController: ViewController {
        guard let vc = UIApplication.shared.windows.first?.rootViewController as? ViewController else {
            fatalError("Could not get ViewController")
        }
        return vc
    }

    private var path: String {
        guard let directory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            preconditionFailure()
        }
        return (directory as NSString).appendingPathComponent("Game")
    }

    private let fileContentsSample = """
        x01
        x-x-o---
        -xoooo--
        xxxxx---
        -xxxxxo-
        --xoxo--
        --xooxo-
        --------
        --------

        """

    func testSaveGame() {
        setupForSaveGameTest()
        try? viewController.saveGame()
        let savedContents = try? String(contentsOfFile: path, encoding: .utf8)
        let expected = fileContentsSample
        XCTAssertEqual(expected, savedContents)
    }

    func testLoadGame() {
        setupForLoadGameTest()
        let vc = viewController
        try? vc.loadGame()
        XCTAssertEqual(.dark, vc.getTurn())
        XCTAssertEqual(0, vc.segmentControlForDark()?.selectedSegmentIndex)
        XCTAssertEqual(1, vc.segmentControlForLight()?.selectedSegmentIndex)
        validateLine0OfBoardView(at: vc)
        validateLine1OfBoardView(at: vc)
        validateLine2OfBoardView(at: vc)
        validateLine3OfBoardView(at: vc)
        validateLine4OfBoardView(at: vc)
        validateLine5OfBoardView(at: vc)
    }

    private func setupForLoadGameTest() {
        try? fileContentsSample.write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func setupForSaveGameTest() {
        let vc = viewController
        vc.newGame()
        vc.changeTurn(to: .dark)
        vc.segmentControlForDark()?.selectedSegmentIndex = 0
        vc.segmentControlForLight()?.selectedSegmentIndex = 1
        setupLine0OfBoardViewForSaveGameTest(at: vc)
        setupLine1OfBoardViewForSaveGameTest(at: vc)
        setupLine2OfBoardViewForSaveGameTest(at: vc)
        setupLine3OfBoardViewForSaveGameTest(at: vc)
        setupLine4OfBoardViewForSaveGameTest(at: vc)
        setupLine5OfBoardViewForSaveGameTest(at: vc)
    }

    private func setupLine0OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 0, y: 0)
        vc.set(disk: .dark, atX: 2, y: 0)
        vc.set(disk: .light, atX: 4, y: 0)
    }

    private func setupLine1OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 1, y: 1)
        vc.set(disk: .light, atX: 2, y: 1)
        vc.set(disk: .light, atX: 3, y: 1)
        vc.set(disk: .light, atX: 4, y: 1)
        vc.set(disk: .light, atX: 5, y: 1)
    }

    private func setupLine2OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 0, y: 2)
        vc.set(disk: .dark, atX: 1, y: 2)
        vc.set(disk: .dark, atX: 2, y: 2)
        vc.set(disk: .dark, atX: 3, y: 2)
        vc.set(disk: .dark, atX: 4, y: 2)
    }

    private func setupLine3OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 1, y: 3)
        vc.set(disk: .dark, atX: 2, y: 3)
        vc.set(disk: .dark, atX: 3, y: 3)
        vc.set(disk: .dark, atX: 4, y: 3)
        vc.set(disk: .dark, atX: 5, y: 3)
        vc.set(disk: .light, atX: 6, y: 3)
    }

    private func setupLine4OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 2, y: 4)
        vc.set(disk: .light, atX: 3, y: 4)
        vc.set(disk: .dark, atX: 4, y: 4)
        vc.set(disk: .light, atX: 5, y: 4)
    }

    private func setupLine5OfBoardViewForSaveGameTest(at vc: ViewController) {
        vc.set(disk: .dark, atX: 2, y: 5)
        vc.set(disk: .light, atX: 3, y: 5)
        vc.set(disk: .light, atX: 4, y: 5)
        vc.set(disk: .dark, atX: 5, y: 5)
        vc.set(disk: .light, atX: 6, y: 5)
    }

    private func validateLine0OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 0, y: 0))
        XCTAssertEqual(.dark, vc.diskAt(x: 2, y: 0))
        XCTAssertEqual(.light, vc.diskAt(x: 4, y: 0))
    }

    private func validateLine1OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 1, y: 1))
        XCTAssertEqual(.light, vc.diskAt(x: 2, y: 1))
        XCTAssertEqual(.light, vc.diskAt(x: 3, y: 1))
        XCTAssertEqual(.light, vc.diskAt(x: 4, y: 1))
        XCTAssertEqual(.light, vc.diskAt(x: 5, y: 1))
    }

    private func validateLine2OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 0, y: 2))
        XCTAssertEqual(.dark, vc.diskAt(x: 1, y: 2))
        XCTAssertEqual(.dark, vc.diskAt(x: 2, y: 2))
        XCTAssertEqual(.dark, vc.diskAt(x: 3, y: 2))
        XCTAssertEqual(.dark, vc.diskAt(x: 4, y: 2))
    }

    private func validateLine3OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 1, y: 3))
        XCTAssertEqual(.dark, vc.diskAt(x: 2, y: 3))
        XCTAssertEqual(.dark, vc.diskAt(x: 3, y: 3))
        XCTAssertEqual(.dark, vc.diskAt(x: 4, y: 3))
        XCTAssertEqual(.dark, vc.diskAt(x: 5, y: 3))
        XCTAssertEqual(.light, vc.diskAt(x: 6, y: 3))
    }

    private func validateLine4OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 2, y: 4))
        XCTAssertEqual(.light, vc.diskAt(x: 3, y: 4))
        XCTAssertEqual(.dark, vc.diskAt(x: 4, y: 4))
        XCTAssertEqual(.light, vc.diskAt(x: 5, y: 4))
    }

    private func validateLine5OfBoardView(at vc: ViewController) {
        XCTAssertEqual(.dark, vc.diskAt(x: 2, y: 5))
        XCTAssertEqual(.light, vc.diskAt(x: 3, y: 5))
        XCTAssertEqual(.light, vc.diskAt(x: 4, y: 5))
        XCTAssertEqual(.dark, vc.diskAt(x: 5, y: 5))
        XCTAssertEqual(.light, vc.diskAt(x: 6, y: 5))
    }
}
