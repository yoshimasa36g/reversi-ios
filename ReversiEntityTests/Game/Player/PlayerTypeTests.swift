//
//  PlayerTypeTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/22.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class PlayerTypeTests: XCTestCase {
    // MARK: - test for toPlayer

    func testToPlayerWhenManual() {
        let actual = PlayerType.manual.toPlayer()
        XCTAssertTrue(actual is Human)
    }

    func testToPlayerWhenComputer() {
        let actual = PlayerType.computer.toPlayer()
        XCTAssertTrue(actual is Computer)
    }
}
