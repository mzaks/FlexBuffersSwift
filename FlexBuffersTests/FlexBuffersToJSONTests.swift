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
    
    func testMapWithTuples() {
        let data = try?FlexBuffer.encode([
            "a": CGPoint(x: 1, y: 2),
            "b": CGRect(x: 1, y: 2, width: 3, height: 4),
            "c": CGSize(width: 23, height: 44)
        ] as FlxbValueMap)
        XCTAssertEqual(data!.root!.jsonString, "{\"a\":[1.0,2.0],\"b\":[1.0,2.0,3.0,4.0],\"c\":[23.0,44.0]}")
    }
    
    func testMapWithTuplesAndExplicitValueHandler() {
        FlexBuffer.valueHandler = { flxb, v in
            if let v = v as? CGPoint {
                try flxb.add(value: (Int(v.x), Int(v.y)))
                return true
            }
            return false
        }
        let data = try?FlexBuffer.encode([
            "a": CGPoint(x: 1, y: 2),
            "b": CGRect(x: 1, y: 2, width: 3, height: 4),
            "c": CGSize(width: 23, height: 44)
            ] as FlxbValueMap)
        
        XCTAssertEqual(data!.root!.jsonString, "{\"a\":[1,2],\"b\":[1.0,2.0,3.0,4.0],\"c\":[23.0,44.0]}")
        
        FlexBuffer.valueHandler = nil
    }
    
    func testMapWithData() {
        let data = try?FlexBuffer.encode([
            "a": 123,
            "b": "blabla".data(using: .utf8)!
            ] as FlxbValueMap)
        
        XCTAssertEqual(data!.root!.jsonString, "{\"a\":123,\"b\":\"YmxhYmxh\"}")
        
        FlexBuffer.valueHandler = nil
    }
}
