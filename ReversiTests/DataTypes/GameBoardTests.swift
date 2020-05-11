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
    // MARK: - ViewControllerの処理に影響がないことを確認するテスト 不要になったら消す

    private let helper = ViewControllerHelper()

    func testCountDisksOfViewController() {
        helper.runGame(advantage: .light)
        let darkCount = helper.viewController.countDisks(of: .dark)
        XCTAssertEqual(darkCount, 5)
        let lightCount = helper.viewController.countDisks(of: .light)
        XCTAssertEqual(lightCount, 7)
    }

    func testSideWithMoreDisksOfViewControllerWhenDarkHasAdvantage() {
        helper.runGame(advantage: .dark)
        let result = helper.viewController.sideWithMoreDisks()
        XCTAssertEqual(result, .dark)
    }

    func testSideWithMoreDisksOfViewControllerWhenLightHasAdvantage() {
        helper.runGame(advantage: .light)
        let result = helper.viewController.sideWithMoreDisks()
        XCTAssertEqual(result, .light)
    }

    func testSideWithMoreDisksOfViewControllerWhenTieGame() {
        helper.viewController.newGame()
        let result = helper.viewController.sideWithMoreDisks()
        XCTAssertNil(result)
    }
}
