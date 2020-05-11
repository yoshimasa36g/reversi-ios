//
//  GameStateTests.swift
//  ReversiTests
//
//  Created by yoshimasa36g on 2020/05/11.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import Reversi
import XCTest

final class GameStateTests: XCTestCase {

    // MARK: - ViewControllerのリファクタリング対象メソッドのテスト 不要になったら消す

    private let helper = ViewControllerHelper()

    func testUpdateCountLabelsOnViewController() {
        helper.runGame(advantage: .dark)
        let vc = helper.viewController
        vc.updateCountLabels()
        XCTAssertEqual(vc.getCountLabels()[Disk.dark.index].text, "7")
        XCTAssertEqual(vc.getCountLabels()[Disk.light.index].text, "5")
    }

    func testUpdateMessageViewsWhenDarksTurn() {
        let vc = helper.viewController
        vc.changeTurn(to: .dark)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .dark)
        XCTAssertEqual(vc.getMessageLabel().text, "'s turn")
    }

    func testUpdateMessageViewsWhenLightsTurn() {
        let vc = helper.viewController
        vc.changeTurn(to: .light)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .light)
        XCTAssertEqual(vc.getMessageLabel().text, "'s turn")
    }

    func testUpdateMessageViewsWhenDarkWins() {
        helper.runGame(advantage: .dark)
        let vc = helper.viewController
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .dark)
        XCTAssertEqual(vc.getMessageLabel().text, " won")
    }

    func testUpdateMessageViewsWhenLightsWins() {
        helper.runGame(advantage: .light)
        let vc = helper.viewController
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 24)
        XCTAssertEqual(vc.getMessageDiskView().disk, .light)
        XCTAssertEqual(vc.getMessageLabel().text, " won")
    }

    func testUpdateMessageViewsWhenTied() {
        let vc = helper.viewController
        vc.newGame()
        vc.changeTurn(to: nil)
        vc.updateMessageViews()
        XCTAssertEqual(vc.getMessageDiskSizeConstraint().constant, 0)
        XCTAssertEqual(vc.getMessageLabel().text, "Tied")
    }
}
