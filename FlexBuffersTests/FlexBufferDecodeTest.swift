//
//  FlexBufferDecodeTest.swift
//  FlexBuffers
//
//  Created by Maxim Zaks on 30.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import FlexBuffers

class FlexBufferDecodeTest: XCTestCase {

    func testReadInt8() {
        let data = Data(bytes: [25, 4, 1])
        let v = FlexBuffer.decode(data: data)?.asInt
        XCTAssertEqual(v, 25)
    }
    
    func testReadInt8Negative() {
        let data = Data(bytes: [231, 4, 1])
        let v = FlexBuffer.decode(data: data)?.asInt
        XCTAssertEqual(v, -25)
    }
    
    func testReadInt16() {
        let data = Data(bytes: [1, 4, 5, 2])
        let v = FlexBuffer.decode(data: data)?.asInt
        XCTAssertEqual(v, 1025)
    }
    
    func testReadInt32() {
        let data = Data(bytes: [255, 255, 255, 127, 6, 4])
        let v = FlexBuffer.decode(data: data)?.asInt
        XCTAssertEqual(v, Int(Int32.max))
    }
    
    func testReadInt64() {
        let data = Data(bytes: [255, 255, 255, 255, 255, 255, 255, 127, 7, 8])
        let v = FlexBuffer.decode(data: data)?.asInt
        XCTAssertEqual(v, Int(Int64.max))
    }
    
    func testReadInt64_WithRightAccessor() {
        let data = Data(bytes: [255, 255, 255, 255, 255, 255, 255, 127, 7, 8])
        let v = FlexBuffer.decode(data: data)?.asInt64
        XCTAssertEqual(v, Int64.max)
    }
    
    func testReadUInt8() {
        let data = Data(bytes: [25, 8, 1])
        let v = FlexBuffer.decode(data: data)?.asUInt
        XCTAssertEqual(v, 25)
    }
    
    func testReadUInt16() {
        let data = Data(bytes: [1, 4, 9, 2])
        let v = FlexBuffer.decode(data: data)?.asUInt
        XCTAssertEqual(v, 1025)
    }
    
    func testReadUInt32() {
        let data = Data(bytes: [233, 1, 1, 0, 10, 4])
        let v = FlexBuffer.decode(data: data)?.asUInt
        XCTAssertEqual(v, 66025)
    }
    
    func testReadUInt64() {
        let data = Data(bytes: [255, 255, 255, 255, 255, 255, 255, 255, 11, 8])
        let v = FlexBuffer.decode(data: data)?.asUInt
        XCTAssertEqual(v, UInt(UInt64.max))
    }
    
    func testReadUInt64_WithRightAccessor() {
        let data = Data(bytes: [255, 255, 255, 255, 255, 255, 255, 255, 11, 8])
        let v = FlexBuffer.decode(data: data)?.asUInt64
        XCTAssertEqual(v, UInt64.max)
    }
    
    func testReadFloat() {
        let data = Data(bytes: [0, 0, 144, 64, 14, 4])
        let v = FlexBuffer.decode(data: data)?.asFloat
        XCTAssertEqual(v, 4.5)
    }
    
    func testReadFloat_fromDouble() {
        let data = Data(bytes: [0, 0, 0, 0, 0, 0, 18, 64, 15, 8])
        let v = FlexBuffer.decode(data: data)?.asFloat
        XCTAssertEqual(v, 4.5)
    }
    
    func testReadDouble_fromFloat() {
        let data = Data(bytes: [0, 0, 144, 64, 14, 4])
        let v = FlexBuffer.decode(data: data)?.asDouble
        XCTAssertEqual(v, 4.5)
    }
    
    func testReadDouble() {
        let data = Data(bytes: [0, 0, 0, 0, 0, 0, 18, 64, 15, 8])
        let v = FlexBuffer.decode(data: data)?.asFloat
        XCTAssertEqual(v, 4.5)
    }
    
    func testReadTrue() {
        let data = Data(bytes: [1, 4, 1])
        let v = FlexBuffer.decode(data: data)?.asBool
        XCTAssertEqual(v, true)
    }
    
    func testReadFalse() {
        let data = Data(bytes: [0, 4, 1])
        let v = FlexBuffer.decode(data: data)?.asBool
        XCTAssertEqual(v, false)
    }
    
    func testReadBadBool() {
        let data = Data(bytes: [2, 4, 1])
        let v = FlexBuffer.decode(data: data)?.asBool
        XCTAssertEqual(v, nil)
    }
    
    func testReadString() {
        let data = Data(bytes: [5, 77, 97, 120, 105, 109, 0, 6, 20, 1])
        let v = FlexBuffer.decode(data: data)?.asString
        XCTAssertEqual(v, "Maxim")
    }
    
    func testReadVectorOfStrings() {
        let data = Data(bytes: [3, 102, 111, 111, 0, 3, 98, 97, 114, 0, 3, 98, 97, 122, 0, 3, 15, 11, 7, 20, 20, 20, 6, 40, 1])
        let v = FlexBuffer.decode(data: data)?.asVector
        XCTAssertEqual(v?.count, 3)
        XCTAssertEqual(v?[0]?.asString, "foo")
        XCTAssertEqual(v?[1]?.asString, "bar")
        XCTAssertEqual(v?[2]?.asString, "baz")
    }
    
    func testReadMixedVector() {
        let data = Data(bytes: [1, 61, 4, 2, 3, 64, 40, 4, 4, 40, 1])
        let v = FlexBuffer.decode(data: data)?.asVector
        XCTAssertEqual(v?.count, 2)
        XCTAssertEqual(v?[0]?.asVector?[0]?.asInt, 61)
        XCTAssertEqual(v?[1]?.asInt, 64)
    }
    
    func testReadTypedVector() {
        let data = Data(bytes: [3, 1, 2, 3, 3, 44, 1])
        let v = FlexBuffer.decode(data: data)?.asVector
        XCTAssertEqual(v?.count, 3)
        XCTAssertEqual(v?[0]?.asInt, 1)
        XCTAssertEqual(v?[1]?.asInt, 2)
        XCTAssertEqual(v?[2]?.asInt, 3)
    }
    
    func testIterateOverTypedVector() {
        let data = Data(bytes: [3, 1, 2, 3, 3, 44, 1])
        let v = FlexBuffer.decode(data: data)?.asVector
        var i = 1
        for r in v! {
            XCTAssertEqual(r.asInt, i)
            i += 1
        }
        XCTAssertEqual(i, 4)
        
        let ints = v!.map({$0.asInt})
        
        XCTAssertEqual(ints.count, 3)
        XCTAssertEqual(ints[0], 1)
        XCTAssertEqual(ints[1], 2)
        XCTAssertEqual(ints[2], 3)
    }
    
    func testIterateOverMap() {
        let data = Data(bytes: [97, 0, 1, 3, 1, 1, 1, 12, 4, 2, 36, 1])
        let v = FlexBuffer.decode(data: data)?.asMap
        
        let pairs = v!.map({$0})
        
        XCTAssertEqual(pairs.count, 1)
        XCTAssertEqual(pairs[0].key, "a")
        XCTAssertEqual(pairs[0].value.asInt, 12)
        
        // 99, 0, 45, 97, 0, 236, 98, 0, 0, 0, 240, 64, 100, 0, 0, 0, 57, 180, 200, 118, 190, 15, 76, 64, 4, 22, 20, 27, 16, 4, 1, 4, 27, 25, 32, 19, 24, 34, 28, 35, 8, 36, 1
    }
    
    func testAccessMap() {
        // [a:-20, b:7.5, c:45, d:56.123]
        let data = Data(bytes: [99, 0, 45, 97, 0, 236, 98, 0, 0, 0, 240, 64, 100, 0, 0, 0, 57, 180, 200, 118, 190, 15, 76, 64, 4, 22, 20, 27, 16, 4, 1, 4, 27, 25, 32, 19, 24, 34, 28, 35, 8, 36, 1])
        let v = FlexBuffer.decode(data: data)?.asMap
        XCTAssertEqual(v?.count, 4)
        XCTAssertEqual(v?["a"]?.asInt, -20)
        XCTAssertEqual(v?["b"]?.asFloat, 7.5)
        XCTAssertEqual(v?["c"]?.asUInt64, 45)
        XCTAssertEqual(v?["d"]?.asDouble, 56.123)
        XCTAssertEqual(v?["e"]?.asInt, nil)
        XCTAssertEqual(v?[""]?.asInt, nil)
        XCTAssertEqual(v?["aa"]?.asInt, nil)
    }
    
    func testComplexMap() {
        // { vec: [ -100, "Fred", 4.0 ], bar: [ 1, 2, 3 ], bar3: [ 1, 2, 3 ] foo: 100, mymap { foo: "Fred" } }
        let data = Data(bytes: [118, 101, 99, 0, 4, 70, 114, 101, 100, 0, 0, 0, 0, 0, 128, 64, 3, 156, 13, 7, 4, 20, 34, 98, 97, 114, 0, 3, 1, 2, 3, 98, 97, 114, 51, 0, 1, 2, 3, 102, 111, 111, 0, 109, 121, 109, 97, 112, 0, 1, 11, 1, 1, 1, 49, 20, 5, 34, 27, 20, 17, 61, 5, 1, 5, 37, 30, 100, 14, 52, 44, 72, 4, 36, 40, 10, 36, 1])
        let v = FlexBuffer.decode(data: data)!.asMap!
        
        print(v.map({$0}))
        
        XCTAssertEqual(v.count, 5)
        XCTAssertEqual(v["vec"]?.asVector?[0]?.asInt, -100)
        XCTAssertEqual(v["vec"]?.asVector?[1]?.asString, "Fred")
        XCTAssertEqual(v["vec"]?.asVector?[2]?.asDouble, 4)
        XCTAssertEqual(v["bar"]?.asVector?[0]?.asInt, 1)
        XCTAssertEqual(v["bar"]?.asVector?[1]?.asInt, 2)
        XCTAssertEqual(v["bar"]?.asVector?[2]?.asInt, 3)
//        XCTAssertEqual(v["bar3"]?.asVector?[0]?.asInt, 1)
//        XCTAssertEqual(v["bar3"]?.asVector?[1]?.asInt, 2)
//        XCTAssertEqual(v["bar3"]?.asVector?[2]?.asInt, 3)
        XCTAssertEqual(v["mymap"]?.asMap?.count, 1)
        XCTAssertEqual(v["mymap"]?.asMap?["foo"]?.asString, "Fred")
        XCTAssertEqual(v["foo"]?.asInt, 100)
    }
}
