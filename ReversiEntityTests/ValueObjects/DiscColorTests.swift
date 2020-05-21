//
//  DiscColorTests.swift
//  ReversiEntityTests
//
//  Created by Yoshimasa Aoki on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class DiscColorTests: XCTestCase {
    func testOtherSide() {
        let example = { (subject: DiscColor, expected: DiscColor) in
            XCTAssertEqual(subject.otherSide, expected)
        }
        example(.dark, .light)
        example(.light, .dark)
    }
}
