@testable import Reversi
import XCTest

final class DataStoreTests: XCTestCase {

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
    }

    private func setupForSaveGameTest() {
        let vc = viewController
        vc.newGame()
        vc.changeTurn(to: .dark)
        let segmentedControls = searchSegmentedControls(parent: vc.view)
        segmentedControls.first?.selectedSegmentIndex = 0
        segmentedControls.last?.selectedSegmentIndex = 1
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

    private func searchSegmentedControls(
        parent: UIView,
        results: [UISegmentedControl] = []) -> [UISegmentedControl] {
        var newResults = results
        parent.subviews.forEach { v in
            if let segmentedControl = v as? UISegmentedControl {
                newResults.append(segmentedControl)
            }
            newResults += searchSegmentedControls(parent: v, results: newResults)
        }
        return newResults
    }
}
