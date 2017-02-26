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
        expect(ints: [1,2,3], [3, 1, 2, 3, 3, 44, 1])
    }
    
    func testAddUIntArray() {
        expect(uints: [UInt(1),UInt(2),UInt(3)], [3, 1, 2, 3, 3, 48, 1])
    }
    
    func testAddInt8Array() {
        expect(ints: [1, 2, 3], [3, 1, 2, 3, 3, 44, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt8Array() {
        expect(ints: [1,555,3], [3, 0, 1, 0, 43, 2, 3, 0, 6, 45, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt16Array() {
        expect(ints: [1,55500,3], [3, 0, 0, 0, 1, 0, 0, 0, 204, 216, 0, 0, 3, 0, 0, 0, 12, 46, 1])
    }
    
    func testAddIntWithNumberBiggerThanInt32Array() {
        expect(ints: [1,55555555500,3], [3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 172, 128, 94, 239, 12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 24, 47, 1])
    }
    
    func testAddIntWithNumberBiggerThanUInt32Array() {
        expect(uints: [1,UInt(55555555500),3], [3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 172, 128, 94, 239, 12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 24, 51, 1])
    }
    
    func testAddFloatArray() {
        let a : Float = 1.5
        let b : Float = 2.5
        let c : Float = 3.5
        expect(floats: [a, b, c], [3, 0, 0, 0, 0, 0, 192, 63, 0, 0, 32, 64, 0, 0, 96, 64, 12, 54, 1])
    }
    
    func testAddDoubleArray() {
        expect(doubles: [1.1, 2.2, 3.3], [3, 0, 0, 0, 0, 0, 0, 0, 154, 153, 153, 153, 153, 153, 241, 63, 154, 153, 153, 153, 153, 153, 1, 64, 102, 102, 102, 102, 102, 102, 10, 64, 24, 55, 1])
    }
    
    func testAddBoolArray() {
        expect(bools: [true, false, true], [3, 1, 0, 1, 3, 44, 1])
    }
    
    func testAddVectorWithOneInt() {
        expect([64], [1, 64, 4, 2, 40, 1])
    }
    
    func testAddVectorWithVectorAndOneInt() {
        let flx = FlexBuffer()
        flx.addVector {
            flx.addVector {
                flx.add(value:61)
            }
            flx.add(value:64)
        }
        let encodedData = flx.finish()
        
        // then
        expect(encodedData: encodedData, [1, 61, 4, 2, 3, 64, 40, 4, 4, 40, 1])
    }
    
    func testAddArrayWithVectorAndOneInt() {
        expect([[61], 64], [1, 61, 4, 2, 3, 64, 40, 4, 4, 40, 1])
    }
    
    func testAddVectorWithOneIntAndNulls() {
        // when
        let flx = FlexBuffer()
        flx.addVector {
            flx.addNull()
            flx.addNull()
            flx.add(value:64)
            flx.addNull()
        }
        let encodedData = flx.finish()

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
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(keyString: "a", value: 12)
        }
        let encodedData = flx.finish()
        expect(encodedData: encodedData, [97, 0, 1, 3, 1, 1, 1, 12, 4, 2, 36, 1])
    }
    
    func testAddMapKeyAsStaticString() {
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(key: "a", value: 12)
        }
        let encodedData = flx.finish()
        expect(encodedData: encodedData, [97, 0, 1, 3, 1, 1, 1, 12, 4, 2, 36, 1])
    }
    
    func testAddMapSortKeys() {
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(keyString: "", value: 45)
            flx.add(keyString: "a", value: 12)
        }
        let encodedData = flx.finish()
        
        expect(encodedData: encodedData, [0, 97, 0, 2, 4, 4, 2, 1, 2, 45, 12, 4, 4, 4, 36, 1])
    }
    
    func testAddUntypedMap() {
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(keyString: "a", value: 12)
            flx.add(keyString: "", value: 45)
        }
        let encodedData = flx.finish()
        // then
        expect(encodedData: encodedData, [97, 0, 0, 2, 2, 5, 2, 1, 2, 45, 12, 4, 4, 4, 36, 1])
    }
    
    func testAddMapComplex() {
        
        
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(key: "age", value: 35)
            flx.addVector(key: "flags"){
                flx.add(value: true)
                flx.add(value: false)
                flx.add(value: true)
                flx.add(value: true)
            }
            flx.add(key: "weight", value: 72.5)
            flx.add(key: "name", value: "Maxim")
            flx.addMap(key: "address"){
                flx.add(key: "city", value: "Bla")
                flx.add(key: "zip", value: "12345")
                flx.add(key: "countryCode", value: "XX")
            }
        }
        let encodedData = flx.finish()
        
        expect(encodedData: encodedData, [97, 103, 101, 0, 102, 108, 97, 103, 115, 0, 4, 1, 0, 1, 1, 4, 4, 4, 4, 119, 101, 105, 103, 104, 116, 0, 110, 97, 109, 101, 0, 5, 77, 97, 120, 105, 109, 0, 97, 100, 100, 114, 101, 115, 115, 0, 99, 105, 116, 121, 0, 3, 66, 108, 97, 0, 122, 105, 112, 0, 5, 49, 50, 51, 52, 53, 0, 99, 111, 117, 110, 116, 114, 121, 67, 111, 100, 101, 0, 2, 88, 88, 0, 3, 38, 18, 30, 3, 1, 3, 38, 11, 31, 20, 20, 20, 5, 59, 98, 95, 74, 82, 0, 0, 7, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0, 0, 26, 0, 0, 0, 35, 0, 0, 0, 113, 0, 0, 0, 96, 0, 0, 0, 0, 0, 145, 66, 36, 6, 40, 20, 14, 25, 38, 1])
    }
    
    func testMapWithIndirectValues() {
        
        let flx = FlexBuffer()
        flx.addMap {
            flx.add(keyString: "c", indirectValue: UInt64(45))
            flx.add(keyString: "a", indirectValue: -20)
            flx.add(keyString: "b", indirectValue: Float(7.5))
            flx.add(keyString: "d", indirectValue: 56.123)
        }
        let encodedData = flx.finish()
        
        expect(encodedData: encodedData, [99, 0, 45, 97, 0, 236, 98, 0, 0, 0, 240, 64, 100, 0, 0, 0, 57, 180, 200, 118, 190, 15, 76, 64, 4, 22, 20, 27, 16, 4, 1, 4, 27, 25, 32, 19, 24, 34, 28, 35, 8, 36, 1])
    }
    
    func testVectorWithIndirectValues() {
        
        let flx = FlexBuffer()
        flx.addVector {
            flx.add(indirectValue: UInt64(45))
            flx.add(indirectValue: -20)
            flx.add(indirectValue: Float(7.5))
            flx.add(indirectValue: Double(56.123))
        }
        let encodedData = flx.finish()
        
        expect(encodedData: encodedData, [45, 236, nil, nil, 0, 0, 240, 64, 57, 180, 200, 118, 190, 15, 76, 64, 4, 17, 17, 15, 12, 28, 24, 34, 35, 8, 40, 1])
    }
    
    func testGrowInternalBuffer() {
        let flx = FlexBuffer(initialSize: 1, options: [])
        
        flx.add(value:25)
        expect(encodedData: flx.finish(), [25, 4, 1])
    }
    
    func expect(_ v : Any, _ data : [UInt8]){
        let _data = FlexBuffer.encodeInefficientButConvinient(v)
        // then
        XCTAssertEqual([UInt8](_data), data)
    }
    
    func expect(bools vs : [Bool], _ data : [UInt8]){
        let flx = FlexBuffer()
        flx.add(array:vs)
        let encodedData = flx.finish()
        // then
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(ints vs : [Int], _ data : [UInt8]){
        let flx = FlexBuffer()
        flx.add(array:vs)
        let encodedData = flx.finish()
        // then
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(uints vs : [UInt], _ data : [UInt8]){
        let flx = FlexBuffer()
        flx.add(array:vs)
        let encodedData = flx.finish()
        // then
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(doubles vs : [Double], _ data : [UInt8]){
        let flx = FlexBuffer()
        flx.add(array:vs)
        let encodedData = flx.finish()
        // then
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(floats vs : [Float], _ data : [UInt8]){
        let flx = FlexBuffer()
        flx.add(array:vs)
        let encodedData = flx.finish()
        // then
        XCTAssertEqual([UInt8](encodedData), data)
    }
    
    func expect(encodedData : Data, _ data : [UInt8?]){
        let encoded = [UInt8](encodedData)
        for pair in zip(encoded, data) {
            if pair.1 != nil {
                XCTAssertEqual(pair.0, pair.1, "\(pair.0) != \(pair.1) in [\(encoded) - \(data)]")
            }
        }
    }
}
