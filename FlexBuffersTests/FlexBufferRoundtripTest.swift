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
        
        let data = try!FlexBuffer.encodeMap {
            try!$0.vector(key: "vec") {
                try!$0.add(-100)
                try!$0.add("Fred")
                try!$0.add(4.0)
            }
            try!$0.add(key: "bar", value: [1,2,3])
            try!$0.vector(key: "bar3"){
                try!$0.add(1)
                try!$0.add(2)
                try!$0.add(3)
            }
            try!$0.add(key: "foo", value: 100)
            try!$0.map(key: "mymap") {
                try!$0.add(key: "foo", value: "Fred")
            }
        }
        
        let v = FlexBuffer.decode(data: data)!.asMap!
        
        print(data.count)
        print("{vec:[-100,\"Fred\",4.0],bar:[1,2,3],bar3:[1,2,3]foo:100,mymap{foo:\"Fred\"}}".characters.count)
        
        XCTAssertEqual(v.count, 5)
        XCTAssertEqual(v["vec"]?.asVector?[0]?.asInt, -100)
        XCTAssertEqual(v["vec"]?.asVector?[1]?.asString, "Fred")
        XCTAssertEqual(v["vec"]?.asVector?[2]?.asDouble, 4)
        XCTAssertEqual(v["bar"]?.asVector?[0]?.asInt, 1)
        XCTAssertEqual(v["bar"]?.asVector?[1]?.asInt, 2)
        XCTAssertEqual(v["bar"]?.asVector?[2]?.asInt, 3)
        XCTAssertEqual(v["bar3"]?.asVector?[0]?.asInt, 1)
        XCTAssertEqual(v["bar3"]?.asVector?[1]?.asInt, 2)
        XCTAssertEqual(v["bar3"]?.asVector?[2]?.asInt, 3)
        XCTAssertEqual(v["mymap"]?.asMap?.count, 1)
        XCTAssertEqual(v["mymap"]?.asMap?["foo"]?.asString, "Fred")
        XCTAssertEqual(v["foo"]?.asInt, 100)
    }

    func test2(){
        let data = try!FlexBuffer.encodeMap{
            try!$0.add(key: "age", value:35)
            try!$0.add(key: "flags", value:[true, false, true, true])
            try!$0.add(key: "weight", value:72.5)
            try!$0.map(key: "address"){
                try!$0.add(key: "city", value:"Bla")
                try!$0.add(key: "zip", value:"12345")
                try!$0.add(key: "countryCode", value:"XX")
            }
        }
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
    
    func test3(){
        let data = try!FlexBuffer.encode([
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
    
    /*
    func test4(){
        let data = try! FlexBuffer.encode([
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
    }*/
    
    func test5(){
        let data = try!FlexBuffer.encodeMap { b in
            try b.vector(key: "list"){ b in
                for i in 0..<3 { // 0xABADCAFEABADCAFE will overflow in usage
                    let ident : UInt64 = 0xABADCAFE + UInt64(i)
                    try b.map {
                        try $0.map(key: "sibling", {
                            try $0.map(key: "parent", {
                                try $0.add(key: "id", value: ident)
                                try $0.add(key: "count", value: 10000 + i)
                                try $0.add(key: "prefix", value: 64 + i)
                                try $0.add(key: "length", value: UInt32(1000000 + i))
                            })
                            try $0.add(key: "time", value: 123456 + i)
                            try $0.add(key: "ratio", value: 3.14159 + Float(i))
                            try $0.add(key: "size", value: UInt16(10000 + i))
                        })
                        try $0.add(key: "name", value: "Hello World!")
                        try $0.add(key: "rating", value: 3.1415432432445543543+Double(i))
                        try $0.add(key: "postfix", value: UInt8(33 + i))
                    }
                }
            }
            try b.add(key: "location", value: "http://google.com/flatbuffers/")
            try b.add(key: "initialized", value: true)
            try b.add(key: "fruit", value: 2)
        }
        
        print(data.flatMap{$0})
        
        let v = FlexBuffer.decode(data: data)!.asMap!
        XCTAssertEqual(v.count, 4)
        XCTAssertEqual(v["fruit"]?.asInt, 2)
        XCTAssertEqual(v["initialized"]?.asBool, true)
        XCTAssertEqual(v["location"]?.asString, "http://google.com/flatbuffers/")
        
        XCTAssertEqual(v["list"]?.asVector?.count, 3)
        XCTAssertEqual(v["list"]?.asVector?[0]?.asMap?.count, 4)
        XCTAssertEqual(v["list"]?.asVector?[0]?.asMap?["name"]?.asString, "Hello World!")
        XCTAssertEqual(v["list"]?.asVector?[0]?.asMap?["rating"]?.asDouble, 3.1415432432445543543 + 0)
        XCTAssertEqual(v["list"]?.asVector?[0]?.asMap?["postfix"]?.asUInt, 33 + 0)
        
        
        XCTAssertEqual(v["list"]?.asVector?[1]?.asMap?.count, 4)
        XCTAssertEqual(v["list"]?.asVector?[1]?.asMap?["name"]?.asString, "Hello World!")
        XCTAssertEqual(v["list"]?.asVector?[1]?.asMap?["rating"]?.asDouble, 3.1415432432445543543 + 1)
        XCTAssertEqual(v["list"]?.asVector?[1]?.asMap?["postfix"]?.asUInt, 33 + 1)
        
        
        XCTAssertEqual(v["list"]?.asVector?[2]?.asMap?.count, 4)
        XCTAssertEqual(v["list"]?.asVector?[2]?.asMap?["name"]?.asString, "Hello World!")
        XCTAssertEqual(v["list"]?.asVector?[2]?.asMap?["rating"]?.asDouble, 3.1415432432445543543 + 2)
        XCTAssertEqual(v["list"]?.asVector?[2]?.asMap?["postfix"]?.asUInt, 33 + 2)
    }
}
