//
//  main.swift
//  FlexBuffersPerformanceTest
//
//  Created by Maxim Zaks on 02.01.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import Foundation

func createContainer() throws -> Data {
    return try FlexBuffer.encodeMap { b in
        try b.vector(key: "list"){ b in
            for i in 0..<3 { // 0xABADCAFEABADCAFE will overflow in usage
                let ident : UInt64 = 0xABADCAFE + UInt64(i)
                try b.map {
                    try $0.map(key: "sibling", {
                        try $0.map(key: "parent", {
                            try $0.add(key: "id", indirectValue: ident)
                            try $0.add(key: "count", value: 10000 + i)
                            try $0.add(key: "prefix", value: 64 + i)
                            try $0.add(key: "length", value: UInt32(1000000 + i))
                        })
                        try $0.add(key: "time", value: 123456 + i)
                        try $0.add(key: "ratio", indirectValue: 3.14159 + Float(i))
                        try $0.add(key: "size", value: UInt16(10000 + i))
                    })
                    try $0.add(key: "name", value: "Hello, World!")
                    try $0.add(key: "rating", indirectValue: 3.1415432432445543543+Double(i))
                    try $0.add(key: "postfix", value: UInt8(33 + i))
                }
            }
        }
        try b.add(key: "location", value: "http://google.com/flatbuffers/")
        try b.add(key: "initialized", value: true)
        try b.add(key: "fruit", value: 2)
    }
}

func create() -> Data {
    return try! FlexBuffer.encode([
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
        "location" : "http://google.com/flatbuffers/",
        "initialized" : true,
        "fruit" : 2
    ])
}

private func use(_ data : Data, start : Int) -> Int
{
    var sum:Int = Int(start)
    let root = FlexBuffer.decode(data: data)!.asMap!
    sum = sum &+ root["location"]!.asString!.utf8.count
    sum = sum &+ root["fruit"]!.asInt!
    sum = sum &+ (root["initialized"]!.asBool! ? 1 : 0)
    
    let list = root["list"]!.asVector!
    for i in 0..<list.count {
        let foobar = list[i]!.asMap!
        sum = sum &+ foobar["name"]!.asString!.utf8.count
        sum = sum &+ Int(foobar["postfix"]!.asUInt!)
        sum = sum &+ Int(foobar["rating"]!.asDouble!)
        
        let bar = foobar["sibling"]!.asMap!
        
        sum = sum &+ Int(bar["ratio"]!.asFloat!)
        sum = sum &+ Int(bar["size"]!.asUInt!)
        sum = sum &+ bar["time"]!.asInt!
        
        let foo = bar["parent"]!.asMap!
        sum = sum &+ foo["count"]!.asInt!
        sum = sum &+ Int(foo["id"]!.asUInt!)
        sum = sum &+ Int(foo["length"]!.asUInt!)
        sum = sum &+ foo["prefix"]!.asInt!
    }
    return sum
}



let data = try!createContainer()
let data2 = create()

print(data)

let sum = use(data2, start: 0)

print(sum)
