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
    
    func test3(){
        let data = try!FlexBuffer.encodeInefficientButConvenient([
            "age" : 35,
            "flags" : [true, false, true, true],
            "weight" : 72.5,
            "address" : [
                "city" : "Bla",
                "zip" : "12345",
                "countryCode" : "XX"
            ]
        ])
        let v = FlexBuffer.decode(data: data)!.asMap!
        XCTAssertEqual(v.count, 4)
        XCTAssertEqual(v["age"]?.asInt, 35)
        XCTAssertEqual(v["flags"]?.asVector?.count, 4)
        XCTAssertEqual(v["flags"]?.asVector?[0]?.asBool, true)
        XCTAssertEqual(v["flags"]?.asVector?[1]?.asBool, false)
        XCTAssertEqual(v["flags"]?.asVector?[2]?.asBool, true)
        XCTAssertEqual(v["flags"]?.asVector?[3]?.asBool, true)
        XCTAssertEqual(v["weight"]?.asFloat, 72.5)
        XCTAssertEqual(v["address"]?.asMap?.count, 3)
        XCTAssertEqual(v["address"]?.asMap?["city"]?.asString, "Bla")
        XCTAssertEqual(v["address"]?.asMap?["zip"]?.asString, "12345")
        XCTAssertEqual(v["address"]?.asMap?["countryCode"]?.asString, "XX")
    }
    
    
    func test4(){
        let data = try!FlexBuffer.encodeInefficientButConvenient([
            "location" : "http://google.com/flatbuffers/",
            "initialized" : true,
            "fruit" : 2,
            "list" : [
                [
                    "sibling" : [
                        "parent" : [
                            "id" : 0xABADCAFE + UInt64(0),
                            "count" : 10000 + 0,
                            "prefix" : 64 + 0,
                            "length" : UInt32(1000000 + 0)
                        ],
                        "time" : 123456 + 0,
                        "ratio" : 3.14159 + Float(0),
                        "rating" : 3.1415432432445543543+Double(0),
                        "postfix" : UInt8(33 + 0)
                    ]
                ],
                [
                    "sibling" : [
                        "parent" : [
                            "id" : 0xABADCAFE + UInt64(1),
                            "count" : 10000 + 1,
                            "prefix" : 64 + 1,
                            "length" : UInt32(1000000 + 1)
                        ],
                        "time" : 123456 + 1,
                        "ratio" : 3.14159 + Float(1),
                        "rating" : 3.1415432432445543543+Double(1),
                        "postfix" : UInt8(33 + 1)
                    ]
                ],
                [
                    "sibling" : [
                        "parent" : [
                            "id" : 0xABADCAFE + UInt64(2),
                            "count" : 10000 + 2,
                            "prefix" : 64 + 2,
                            "length" : UInt32(1000000 + 2)
                        ],
                        "time" : 123456 + 2,
                        "ratio" : 3.14159 + Float(2),
                        "rating" : 3.1415432432445543543+Double(2),
                        "postfix" : UInt8(33 + 2)
                    ]
                ]
            ],

            ])
        let v = FlexBuffer.decode(data: data)!.asMap!
        XCTAssertEqual(v.count, 4)
        XCTAssertEqual(v["fruit"]?.asInt, 2)
        XCTAssertEqual(v["initialized"]?.asBool, true)
        XCTAssertEqual(v["location"]?.asString, "http://google.com/flatbuffers/")
        XCTAssertEqual(v["list"]?.asVector?.count, 3)
        XCTAssertEqual(v["list"]?[1]?["sibling"]?["parent"]?["prefix"]?.asInt, 65)
        XCTAssertEqual(v["list"]?.count, 3)
    }
}
