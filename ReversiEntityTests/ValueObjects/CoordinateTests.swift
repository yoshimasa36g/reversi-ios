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
    func testAdjacent() {
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .upperLeft), Coordinate(x: 3, y: 3))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .upper), Coordinate(x: 4, y: 3))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .upperRight), Coordinate(x: 5, y: 3))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .right), Coordinate(x: 5, y: 4))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .lowerRight), Coordinate(x: 5, y: 5))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .lower), Coordinate(x: 4, y: 5))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .lowerLeft), Coordinate(x: 3, y: 5))
        XCTAssertEqual(Coordinate(x: 4, y: 4).adjacent(to: .left), Coordinate(x: 3, y: 4))
    }
}
