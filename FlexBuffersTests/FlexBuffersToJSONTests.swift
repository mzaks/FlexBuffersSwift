//
//  FlexBuffersToJSONTests.swift
//  FlexBuffers
//
//  Created by Maxim Zaks on 10.08.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import XCTest
import FlexBuffers

class FlexBuffersToJSONTests: XCTestCase {

    func testBoolVector() {
        let data = try?FlexBuffer.encode([true, false, true] as FlxbValueVector)
        XCTAssertEqual(data!.root!.jsonString, "[true,false,true]")
    }
    
    func testIntVector() {
        let data = try?FlexBuffer.encode([1, 0, 1] as FlxbValueVector)
        XCTAssertEqual(data!.root!.jsonString, "[1,0,1]")
    }

    func testMixedNumbersVector() {
        let data = try?FlexBuffer.encode([1, 0.0, 1.5] as FlxbValueVector)
        XCTAssertEqual(data!.root!.jsonString, "[1,0.0,1.5]")
    }
    
    func testMap() {
        let data = try?FlexBuffer.encode(["a": true, "b": 1, "c": FlxbValueNil(), "d":1.5] as FlxbValueMap)
        XCTAssertEqual(data!.root!.jsonString, "{\"a\":true,\"b\":1,\"c\":null,\"d\":1.5}")
    }
}
