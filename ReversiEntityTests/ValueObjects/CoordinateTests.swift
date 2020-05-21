//
//  CoordinateTests.swift
//  ReversiEntityTests
//
//  Created by yoshimasa36g on 2020/05/21.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiEntity
import XCTest

final class CoordinateTests: XCTestCase {
    func testAdd() {
        let randomPosition = { Int.random(in: -10..<10) }
        (0..<10).forEach { _ in
            let subject = Coordinate(x: randomPosition(), y: randomPosition())
            let other = Coordinate(x: randomPosition(), y: randomPosition())
            let expected = Coordinate(x: subject.x + other.x,
                                      y: subject.y + other.y)
            XCTAssertEqual(subject.add(other), expected)
        }
    }
}
