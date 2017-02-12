//
//  FlexBuffersTests.swift
//  FlexBuffersTests
//
//  Created by Maxim Zaks on 27.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import FlexBuffers

class FlexBufferBuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddNil() {
        expect(NSNull(), [0,0,1])
    }
    
    func testAddTrue() {
        expect(true, [1, 4, 1])
    }
    
    func testAddFalse() {
        expect(false, [0, 4, 1])
    }
    
    func testAddUInt8() {
        expect(UInt8(230), [230, 8, 1])
    }
    
    func testAddInt8() {
        let v : Int8 = 25
        expect(v, [25, 4, 1])
    }
    
    func testAddInt8NegativNumber() {
        let v : Int8 = -25
        expect(v, [231, 4, 1])
    }
    
    func testAddSmallInt16() {
        let v : Int16 = 25
        expect(v, [25, 4, 1])
    }
    
    func testAddBigInt16() {
        let v : Int16 = 1025
        expect(v, [1, 4, 5, 2])
    }
    
    func testAddSmallUInt16() {
        let v : UInt16 = 25
        expect(v, [25, 8, 1])
    }
    
    func testAddBigUInt16() {
        let v : UInt16 = 1025
        expect(v, [1, 4, 9, 2])
    }
    
    func testAddSmallInt32() {
        let v : Int32 = 25
        expect(v, [25, 4, 1])
    }
    
    func testAddMidInt32() {
        let v : Int32 = 1025
        expect(v, [1, 4, 5, 2])
    }
    
    func testAddBigInt32() {
        let v : Int32 = Int32.max
        expect(v, [255, 255, 255, 127, 6, 4])
    }
    
    func testAddSmallUInt32() {
        let v : UInt32 = 25
        expect(v, [25, 8, 1])
    }
    
    func testAddMidUInt32() {
        let v : UInt32 = 1025
        expect(v, [1, 4, 9, 2])
    }
    
    func testAddBigUInt32() {
        let v : UInt32 = UInt32.max
        expect(v, [255, 255, 255, 255, 10, 4])
    }
    
    func testAddTinyInt64() {
        let v : Int64 = 25
        expect(v, [25, 4, 1])
    }
    
    func testAddSmallInt64() {
        let v : Int64 = 1025
        expect(v, [1, 4, 5, 2])
    }
    
    func testAddMidInt64() {
        let v : Int64 = 60025
        expect(v, [121, 234, 0, 0, 6, 4])
    }
    
    func testAddBigInt64() {
        let v : Int64 = Int64.max
        expect(v, [255, 255, 255, 255, 255, 255, 255, 127, 7, 8])
    }
    
    func testAddTinyUInt64() {
        let v : UInt64 = 25
        expect(v, [25, 8, 1])
    }
    
    func testAddSmallUInt64() {
        let v : UInt64 = 1025
        expect(v, [1, 4, 9, 2])
    }
    
    func testAddMidUInt64() {
        let v : UInt64 = 66025
        expect(v, [233, 1, 1, 0, 10, 4])
    }
    
    func testAddBigUInt64() {
        let v : UInt64 = UInt64.max
        expect(v, [255, 255, 255, 255, 255, 255, 255, 255, 11, 8])
    }
    
    func testAddBigInt() {
        let v : Int = Int.max
        expect(v, [255, 255, 255, 255, 255, 255, 255, 127, 7, 8])
    }
    
    func testAddBigIntNegativeValue() {
        let v : Int = Int.min
        expect(v, [0, 0, 0, 0, 0, 0, 0, 128, 7, 8])
    }
    
    func testAddBigUInt() {
        let v : UInt = UInt.max
        expect(v, [255, 255, 255, 255, 255, 255, 255, 255, 11, 8])
    }
    
    func testAddFloat() {
        let v : Float = 4.5
        expect(v, [0, 0, 144, 64, 14, 4])
    }
    
    func testAddDouble() {
        let v : Double = 0.1
        expect(v, [154, 153, 153, 153, 153, 153, 185, 63, 15, 8])
    }
    
    func testAddDoubleWhichCanBeRepresentedAsFloat() {
        let v : Double = 4.5
        expect(v, [0, 0, 144, 64, 14, 4])
    }
    
    func testAddString() {
        expect("Maxim", [5, 77, 97, 120, 105, 109, 0, 6, 20, 1])
    }
    
    func testAddIntArray() {
        expect(typed: [1,2,3], [3, 1, 2, 3, 3, 44, 1])
    }
    
    func testAddUIntArray() {
        expect(typed: [UInt(1),UInt(2),UInt(3)], [3, 1, 2, 3, 3, 48, 1])
    }
    
    func testAddInt8Array() {
        expect(typed: [Int8(1),Int8(2),Int8(3)], [3, 1, 2, 3, 3, 44, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt8Array() {
        expect(typed: [1,555,3], [3, 0, 1, 0, 43, 2, 3, 0, 6, 45, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt16Array() {
        expect(typed: [1,55500,3], [3, 0, 0, 0, 1, 0, 0, 0, 204, 216, 0, 0, 3, 0, 0, 0, 12, 46, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt32Array() {
        expect(typed: [1,55555555500,3], [3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 172, 128, 94, 239, 12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 24, 47, 1])
    }
    
    func testAddIntWithNumberBiggerThanUInt32Array() {
        expect(typed: [1,UInt(55555555500),3], [3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 172, 128, 94, 239, 12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 24, 51, 1])
    }
    
    func testAddFloatArray() {
        let a : Float = 1.5
        let b : Float = 2.5
        let c : Float = 3.5
        expect(typed: [a, b, c], [3, 0, 0, 0, 0, 0, 192, 63, 0, 0, 32, 64, 0, 0, 96, 64, 12, 54, 1])
    }
    
    func testAddDoubleArray() {
        expect(typed: [1.1, 2.2, 3.3], [3, 0, 0, 0, 0, 0, 0, 0, 154, 153, 153, 153, 153, 153, 241, 63, 154, 153, 153, 153, 153, 153, 1, 64, 102, 102, 102, 102, 102, 102, 10, 64, 24, 55, 1])
    }
    
    func testAddBoolArray() {
        expect(typed: [true, false, true], [3, 1, 0, 1, 3, 44, 1])
    }
    
    func testAddVectorWithOneInt() {
        expect([64], [1, 64, 4, 2, 40, 1])
    }
    
    func testAddVectorWithVectorAndOneInt() {
        let encodedData = try!FlexBuffer.encodeVector{
            try!$0.vector{
                try!$0.add(61)
            }
            try!$0.add(64)
        }
        
        // then
        expect(encodedData: encodedData, [1, 61, 4, 2, 3, 64, 40, 4, 4, 40, 1])
    }
    
    func testAddArrayWithVectorAndOneInt() {
        expect([[61], 64], [1, 61, 4, 2, 3, 64, 40, 4, 4, 40, 1])
    }
    
    func testAddVectorWithOneIntAndNulls() {
        // when
        
        let encodedData = try!FlexBuffer.encodeVector{
            try!$0.add(NSNull())
            try!$0.add(NSNull())
            try!$0.add(64)
            try!$0.add(NSNull())
        }
        expect(encodedData: encodedData, [4, 0, 0, 64, 0, 0, 0, 4, 0, 8, 40, 1])
    }
    
    func testAddArrayWithOneIntAndNulls() {
        expect([NSNull(), NSNull(), 64, NSNull()], [4, 0, 0, 64, 0, 0, 0, 4, 0, 8, 40, 1])
    }
    
    func testAddArrayOfStrings() {
        expect(["foo", "bar", "baz"], [3, 102, 111, 111, 0, 3, 98, 97, 114, 0, 3, 98, 97, 122, 0, 3, 15, 11, 7, 20, 20, 20, 6, 40, 1])
    }
    
    func testAddArrayOfFloats() {
        expect([4.5, 78.3, 29.2],
               [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 64, 51, 51, 51, 51, 51, 147, 83, 64, 51, 51, 51, 51, 51, 51, 61, 64, 15, 15, 15, 27, 43, 1])
    }
    
    func testAddMap() {
        let encodedData = try!FlexBuffer.encodeMap{
            try $0.add(key: "a", value: 12)
        }
        expect(encodedData: encodedData, [97, 0, 1, 3, 1, 1, 1, 12, 4, 2, 36, 1])
    }
    
    func testAddMapKeyAsStaticString() {
        let encodedData = try!FlexBuffer.encodeMap{
            try $0.add(key: "a" as StaticString, value: 12)
        }
        expect(encodedData: encodedData, [97, 0, 1, 3, 1, 1, 1, 12, 4, 2, 36, 1])
    }
    
    func testAddMapSortKeys() {
        let encodedData = try!FlexBuffer.encodeMap{
            try $0.add(key: "", value: 45)
            try $0.add(key: "a", value: 12)
        }
        expect(encodedData: encodedData, [0, 97, 0, 2, 4, 4, 2, 1, 2, 45, 12, 4, 4, 4, 36, 1])
    }
    
    func testAddUntypedMap() {
        // when
        let encodedData = try! FlexBuffer.encodeMap {
            try $0.add(key: "a", value: 12)
            try $0.add(key: "", value: 45)
        }
        // then
        expect(encodedData: encodedData, [97, 0, 0, 2, 2, 5, 2, 1, 2, 45, 12, 4, 4, 4, 36, 1])
    }
    
    func testAddMapComplex() {
        let encodedData = try! FlexBuffer.encodeMap {
            try $0.add(key: "age", value: 35)
            try $0.vector(key: "flags"){
                try $0.add(true)
                try $0.add(false)
                try $0.add(true)
                try $0.add(true)
            }
            try $0.add(key: "weight", value: 72.5)
            try $0.add(key: "name", value: "Maxim")
            try $0.map(key: "address"){
                try $0.add(key: "city", value: "Bla")
                try $0.add(key: "zip", value: "12345")
                try $0.add(key: "countryCode", value: "XX")
            }
        }
        expect(encodedData: encodedData, [97, 103, 101, 0, 102, 108, 97, 103, 115, 0, 4, 1, 0, 1, 1, 4, 4, 4, 4, 119, 101, 105, 103, 104, 116, 0, 110, 97, 109, 101, 0, 5, 77, 97, 120, 105, 109, 0, 97, 100, 100, 114, 101, 115, 115, 0, 99, 105, 116, 121, 0, 3, 66, 108, 97, 0, 122, 105, 112, 0, 5, 49, 50, 51, 52, 53, 0, 99, 111, 117, 110, 116, 114, 121, 67, 111, 100, 101, 0, 2, 88, 88, 0, 3, 38, 18, 30, 3, 1, 3, 38, 11, 31, 20, 20, 20, 5, 59, 98, 95, 74, 82, 0, 0, 7, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0, 0, 26, 0, 0, 0, 35, 0, 0, 0, 113, 0, 0, 0, 96, 0, 0, 0, 0, 0, 145, 66, 36, 6, 40, 20, 14, 25, 38, 1])
    }
    
    func testMapWithIndirectValues() {
        let encodedData = try!FlexBuffer.encodeMap{
            try $0.add(key: "c", indirectValue: UInt64(45))
            try $0.add(key: "a", indirectValue: Int64(-20))
            try $0.add(key: "b", indirectValue: Float(7.5))
            try $0.add(key: "d", indirectValue: Double(56.123))
        }
        expect(encodedData: encodedData, [99, 0, 45, 97, 0, 236, 98, 0, 0, 0, 240, 64, 100, 0, 0, 0, 57, 180, 200, 118, 190, 15, 76, 64, 4, 22, 20, 27, 16, 4, 1, 4, 27, 25, 32, 19, 24, 34, 28, 35, 8, 36, 1])
    }
    
    func testVectorWithIndirectValues() {
        let encodedData = try!FlexBuffer.encodeVector{
            try $0.add(indirectValue: UInt64(45))
            try $0.add(indirectValue: Int64(-20))
            try $0.add(indirectValue: Float(7.5))
            try $0.add(indirectValue: Double(56.123))
        }
        expect(encodedData: encodedData, [45, 236, 0, 0, 0, 0, 240, 64, 57, 180, 200, 118, 190, 15, 76, 64, 4, 17, 17, 15, 12, 28, 24, 34, 35, 8, 40, 1])
    }
    
    func expect(_ v : Any, _ data : [UInt8]){
        let _data = try?FlexBuffer.encode(v)
        // then
        guard let encodedData = _data else {
            XCTFail("encoding failed")
            return
        }
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect<T : FlxbScalarValue>(typed vs : [T], _ data : [UInt8]){
        let _data = try?FlexBuffer.encode(typedArray: vs)
        // then
        guard let encodedData = _data else {
            XCTFail("encoding failed")
            return
        }
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(encodedData : Data, _ data : [UInt8]){
        XCTAssertEqual([UInt8](encodedData), data)
    }
}
