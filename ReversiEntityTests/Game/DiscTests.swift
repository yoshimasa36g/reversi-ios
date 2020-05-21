//
//  DiscTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class DiscTests: XCTestCase {
    func testFlipped() {
        XCTAssertEqual(Disc(color: .dark).flipped, Disc(color: .light))
        XCTAssertEqual(Disc(color: .light).flipped, Disc(color: .dark))
    }

    func testDark() {
        XCTAssertEqual(Disc.dark(), Disc(color: .dark))
    }

    func testLight() {
        XCTAssertEqual(Disc.light(), Disc(color: .light))
    }
}
