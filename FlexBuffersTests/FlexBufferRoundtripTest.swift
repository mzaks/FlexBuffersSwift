//
//  FlexBufferRoundtripTest.swift
//  FlexBuffers
//
//  Created by Maxim Zaks on 14.01.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import XCTest
import FlexBuffers


class FlexBufferRoundtripTest: XCTestCase {

    func test1() {
        // {vec:[-100,"Fred",4.0],bar:[1,2,3],bar3:[1,2,3]foo:100,mymap{foo:"Fred"}}
        let flx = FlexBuffer()
        try!flx.addMap {
            try!flx.addVector(key: "vec") {
                flx.add(value: -100)
                flx.add(value: "Fred")
                flx.add(value:4.0)
            }
            try!flx.add(key: "bar", value: [1, 2, 3])
            try!flx.addVector(key: "bar3") {
                flx.add(value:1)
                flx.add(value:2)
                flx.add(value:3)
            }
            flx.add(key: "foo", value: 100)
            try!flx.addMap(key: "mymap") {
                flx.add(key: "foo", value: "Fred")
            }
        }
        let data = try!flx.finish()
        
        let v = FlexBuffer.decode(data: data)!.asMap!
        
        print(v.debugDescription)
        print("{vec:[-100,\"Fred\",4.0],bar:[1,2,3],bar3:[1,2,3]foo:100,mymap{foo:\"Fred\"}}".characters.count)
        
        XCTAssertEqual(v.count, 5)
        XCTAssertEqual(v["vec"]?.asVector?[0]?.asInt, -100)
        XCTAssertEqual(v["vec"]?.asVector?[1]?.count, 4)
        XCTAssertEqual(v["vec"]?.asVector?[1]?.asString, "Fred")
        XCTAssertEqual(v["vec"]?.asVector?[2]?.asDouble, 4)
        XCTAssertEqual(v["bar"]?.asVector?[0]?.asInt, 1)
        XCTAssertEqual(v["bar"]?.asVector?[1]?.asInt, 2)
        XCTAssertEqual(v["bar"]?.asVector?[2]?.asInt, 3)
        XCTAssertEqual(v["bar3"]?.asVector?[0]?.asInt, 1)
        XCTAssertEqual(v["bar3"]?.asVector?[1]?.asInt, 2)
        XCTAssertEqual(v["bar3"]?.asVector?[2]?.asInt, 3)
        XCTAssertEqual(v["mymap"]?.asMap?.count, 1)
        XCTAssertEqual(v["mymap"]?.asMap?["foo"]?.count, 4)
        XCTAssertEqual(v["mymap"]?.asMap?["foo"]?.asString, "Fred")
        XCTAssertEqual(v["foo"]?.asInt, 100)
    }

    func test2(){
        let flx = FlexBuffer()
        try!flx.addMap {
            flx.add(key: "age", value: 35)
            try!flx.add(key: "flags", value: [true, false, true, true])
            flx.add(key: "weight", value: 72.5)
            try!flx.addMap(key: "address"){
                flx.add(key: "city", value: "Bla")
                flx.add(key: "zip", value: "12345")
                flx.add(key: "countryCode", value: "XX")
            }
        }
        let data = try!flx.finish()
        
        let v = FlexBuffer.decode(data: data)!.asMap!
        XCTAssertEqual(v.count, 4)
        XCTAssertEqual(v["age"]?.asInt, 35)
        XCTAssertEqual(v["flags"]?.count, 4)
        XCTAssertEqual(v["flags"]?.asVector?[0]?.asBool, true)
        XCTAssertEqual(v["flags"]?.asVector?[1]?.asBool, false)
        XCTAssertEqual(v["flags"]?.asVector?[2]?.asBool, true)
        XCTAssertEqual(v["flags"]?.asVector?[3]?.asBool, true)
        XCTAssertEqual(v["weight"]?.asFloat, 72.5)
        XCTAssertEqual(v["address"]?.count, 3)
        XCTAssertEqual(v["address"]?.asMap?["city"]?.asString, "Bla")
        XCTAssertEqual(v["address"]?.asMap?["zip"]?.asString, "12345")
        XCTAssertEqual(v["address"]?.asMap?["countryCode"]?.asString, "XX")
    }
    
    func testTuples(){
        let flx = FlexBuffer()
        try!flx.addMap {
            try!flx.add(key: "a", value: (1, 2))
            try!flx.add(key: "b", value: (1.0, 2.5))
            try!flx.add(key: "c", value: (UInt(1), 2))
            try!flx.add(key: "d", value: (1, 2, 3))
            try!flx.add(key: "e", value: (1.0, 2.5, 4.0))
            try!flx.add(key: "f", value: (UInt(1), 2, 3))
            try!flx.add(key: "g", value: (1, 2, 3, 4))
            try!flx.add(key: "h", value: (1.0, 2.5, 4.0, 5.5))
            try!flx.add(key: "i", value: (UInt(1), 2, 3, 4))
        }
        let data = try!flx.finish()
        
        let v = FlexBuffer.decode(data: data)!.asMap!
        XCTAssertEqual(v.count, 9)
        XCTAssertEqual(v["a"]?.asTuppleInt?.0, 1)
        XCTAssertEqual(v["a"]?.asTuppleInt?.1, 2)
        XCTAssertEqual(v["b"]?.asTuppleDouble?.0, 1.0)
        XCTAssertEqual(v["b"]?.asTuppleDouble?.1, 2.5)
        XCTAssertEqual(v["c"]?.asTuppleUInt?.0, 1)
        XCTAssertEqual(v["c"]?.asTuppleUInt?.1, 2)
        XCTAssertEqual(v["d"]?.asTripleInt?.0, 1)
        XCTAssertEqual(v["d"]?.asTripleInt?.1, 2)
        XCTAssertEqual(v["d"]?.asTripleInt?.2, 3)
        XCTAssertEqual(v["e"]?.asTripleDouble?.0, 1)
        XCTAssertEqual(v["e"]?.asTripleDouble?.1, 2.5)
        XCTAssertEqual(v["e"]?.asTripleDouble?.2, 4)
        XCTAssertEqual(v["f"]?.asTripleUInt?.0, 1)
        XCTAssertEqual(v["f"]?.asTripleUInt?.1, 2)
        XCTAssertEqual(v["f"]?.asTripleUInt?.2, 3)
        XCTAssertEqual(v["g"]?.asQuadrupleInt?.0, 1)
        XCTAssertEqual(v["g"]?.asQuadrupleInt?.1, 2)
        XCTAssertEqual(v["g"]?.asQuadrupleInt?.2, 3)
        XCTAssertEqual(v["g"]?.asQuadrupleInt?.3, 4)
        XCTAssertEqual(v["h"]?.asQuadrupleDouble?.0, 1)
        XCTAssertEqual(v["h"]?.asQuadrupleDouble?.1, 2.5)
        XCTAssertEqual(v["h"]?.asQuadrupleDouble?.2, 4)
        XCTAssertEqual(v["h"]?.asQuadrupleDouble?.3, 5.5)
        XCTAssertEqual(v["i"]?.asQuadrupleUInt?.0, 1)
        XCTAssertEqual(v["i"]?.asQuadrupleUInt?.1, 2)
        XCTAssertEqual(v["i"]?.asQuadrupleUInt?.2, 3)
        XCTAssertEqual(v["i"]?.asQuadrupleUInt?.3, 4)
        
        XCTAssertEqual(v["a"]?.asTripleInt?.0, nil)
        XCTAssertEqual(v["a"]?.asQuadrupleInt?.0, nil)
    }
    
    func testTransformVectorToArray(){
        let flx = FlexBuffer()
        try?flx.add(array: [true, true , false, true])
        let data = try!flx.finish()
        
        let v = FlexBuffer.decode(data: data)!.asVector!
        
        let array = v.makeIterator().flatMap{$0.asBool}
        
        XCTAssertEqual(array, [true, true , false, true])
    }
    
    func testStringWithSpecialCharacter() {
        let flx = FlexBuffer()
        flx.add(value: "hello \t \" there / \n\r")
        let flxData = try!flx.finish()
        let flx1 = FlexBuffer.decode(data: flxData)
        XCTAssertEqual(flx1?.debugDescription, "\"hello \\t \\\" there / \\n\\r\"")
        XCTAssertEqual(flx1?.jsonString, "\"hello \\t \\\" there \\/ \\n\\r\"")
        print(flx1!.debugDescription)
    }
    
    func testToDictMethod() {
        let flx = FlexBuffer()
        try? flx.addMap {
            flx.add(key: "bla", value: true)
        }
        let flxData = try?flx.finish()
        let flx1 = FlexBuffer.decode(data: flxData!)
        let dict = flx1?.asMap?.toDict{
            return $0.asBool
        }
        XCTAssertEqual(["bla": true], dict!)
    }
    
    func testFlxbValues() {
        let object = [
            "i": 25,
            "b": true,
            "s": "Hello",
            "ss": "My name is" as StaticString,
            "d": 2.5,
            "u": 45 as UInt,
            "bs": [true, false , true] as FlxbValueVector,
            "bss": [1, 3.4, "abc", FlxbValueNil(), 45] as FlxbValueVector,
            "o": ["a": 12] as FlxbValueMap,
            "vo" : [ ["a": 1]as FlxbValueMap, [1, 2, 3] as FlxbValueVector] as FlxbValueVector
        ] as FlxbValueMap
        let data = try!FlexBuffer.encode(object)
        XCTAssertEqual(data.root?.count, 10)
        XCTAssertEqual(data.root?["i"]?.asInt, 25)
        XCTAssertEqual(data.root?["b"]?.asBool, true)
        XCTAssertEqual(data.root?["s"]?.asString, "Hello")
        XCTAssertEqual(data.root?["ss"]?.asString, "My name is")
        XCTAssertEqual(data.root?["d"]?.asDouble, 2.5)
        XCTAssertEqual(data.root?["u"]?.asUInt, 45)
        XCTAssertEqual(data.root?["bs"]?.count, 3)
        XCTAssertEqual(data.root?["bs"]?[0]?.asBool, true)
        XCTAssertEqual(data.root?["bs"]?[1]?.asBool, false)
        XCTAssertEqual(data.root?["bs"]?[2]?.asBool, true)
        XCTAssertEqual(data.root?["bss"]?.asVector?.count, 5)
        XCTAssertEqual(data.root?["bss"]?[0]?.asInt, 1)
        XCTAssertEqual(data.root?["bss"]?[1]?.asDouble, 3.4)
        XCTAssertEqual(data.root?["bss"]?[2]?.asString, "abc")
        XCTAssertEqual(data.root?["bss"]?[3]?.isNull, true)
        XCTAssertEqual(data.root?["bss"]?[4]?.asInt, 45)
        XCTAssertEqual(data.root?["o"]?.count, 1)
        XCTAssertEqual(data.root?["o"]?["a"]?.asInt, 12)
        XCTAssertEqual(data.root?["vo"]?.count, 2)
        XCTAssertEqual(data.root?["vo"]?[0]?.count, 1)
        XCTAssertEqual(data.root?["vo"]?[0]?["a"]?.asInt, 1)
        XCTAssertEqual(data.root?["vo"]?[1]?.count, 3)
        XCTAssertEqual(data.root?["vo"]?[1]?[0]?.asInt, 1)
        XCTAssertEqual(data.root?["vo"]?[1]?[1]?.asInt, 2)
        XCTAssertEqual(data.root?["vo"]?[1]?[2]?.asInt, 3)
    }
    
    func testFlxbValuesAccessThroughString() {
        let object = [
            "i": 25,
            "b": true,
            "s": "Hello",
            "ss": "My name is" as StaticString,
            "d": 2.5,
            "u": 45 as UInt,
            "bs": [true, false , true] as FlxbValueVector,
            "bss": [1, 3.4, "abc", FlxbValueNil(), 45] as FlxbValueVector,
            "o": ["a": 12] as FlxbValueMap,
            "vo" : [ ["a": 1]as FlxbValueMap, [1, 2, 3] as FlxbValueVector] as FlxbValueVector
            ] as FlxbValueMap
        let data = try!FlexBuffer.encode(object)
        XCTAssertEqual(data.root?.count, 10)
        XCTAssertEqual(data.root?.get(key: "i")?.asInt, 25)
        XCTAssertEqual(data.root?.get(key: "b")?.asBool, true)
        XCTAssertEqual(data.root?.get(key: "s")?.asString, "Hello")
        XCTAssertEqual(data.root?.get(key: "ss")?.asString, "My name is")
        XCTAssertEqual(data.root?.get(key: "d")?.asDouble, 2.5)
        XCTAssertEqual(data.root?.get(key: "u")?.asUInt, 45)
        XCTAssertEqual(data.root?.get(key: "bs")?.count, 3)
        XCTAssertEqual(data.root?.get(key: "bs")?[0]?.asBool, true)
        XCTAssertEqual(data.root?.get(key: "bs")?[1]?.asBool, false)
        XCTAssertEqual(data.root?.get(key: "bs")?[2]?.asBool, true)
        XCTAssertEqual(data.root?.get(key: "bss")?.asVector?.count, 5)
        XCTAssertEqual(data.root?.get(key: "bss")?[0]?.asInt, 1)
        XCTAssertEqual(data.root?.get(key: "bss")?[1]?.asDouble, 3.4)
        XCTAssertEqual(data.root?.get(key: "bss")?[2]?.asString, "abc")
        XCTAssertEqual(data.root?.get(key: "bss")?[3]?.isNull, true)
        XCTAssertEqual(data.root?.get(key: "bss")?[4]?.asInt, 45)
        XCTAssertEqual(data.root?.get(key: "o")?.count, 1)
        XCTAssertEqual(data.root?.get(key: "o")?["a"]?.asInt, 12)
        XCTAssertEqual(data.root?.get(key: "vo")?.count, 2)
        XCTAssertEqual(data.root?.get(key: "vo")?[0]?.count, 1)
        XCTAssertEqual(data.root?.get(key: "vo")?[0]?["a"]?.asInt, 1)
        XCTAssertEqual(data.root?.get(key: "vo")?[1]?.count, 3)
        XCTAssertEqual(data.root?.get(key: "vo")?[1]?[0]?.asInt, 1)
        XCTAssertEqual(data.root?.get(key: "vo")?[1]?[1]?.asInt, 2)
        XCTAssertEqual(data.root?.get(key: "vo")?[1]?[2]?.asInt, 3)
    }
}
