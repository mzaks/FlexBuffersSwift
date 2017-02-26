//
//  main.swift
//  FlexBuffersPerformanceTest
//
//  Created by Maxim Zaks on 02.01.17.
//  Copyright © 2017 Maxim Zaks. All rights reserved.
//

import Foundation


func mach_task_self() -> task_t {
    return mach_task_self_
}

func getMegabytesUsed() -> Float? {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
    let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
        return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
            return task_info(
                mach_task_self(),
                task_flavor_t(MACH_TASK_BASIC_INFO),
                machPtr,
                &count
            )
        }
    }
    guard kerr == KERN_SUCCESS else {
        return nil
    }
    return Float(info.resident_size) / (1024 * 1024)
}

func createContainer(flx : FlexBuffer) throws -> Data {
    flx.addMap {
        flx.add(key: "fruit", value:2)
        flx.add(key: "initialized", value:true)
        flx.addVector(key:"list") {
            for i in 0..<3 {
                let ident : UInt64 = 0xABADCAFE + UInt64(i)
                flx.addMap {
                    flx.add(key: "name", value: "Hello, World!")
                    flx.add(key: "postfix", value: UInt(33 + i))
                    flx.add(key: "rating" , indirectValue: 3.1415432432445543543+Double(i))
                    flx.addMap(key:"sibling") {
                        flx.addMap(key:"parent") {
                            flx.add(key: "count", indirectValue: 10000 + i)
                            flx.add(key: "id", indirectValue: ident)
                            flx.add(key: "length", indirectValue: UInt(1000000 + i))
                            flx.add(key: "prefix", value: 64 + i)
                        }
                        flx.add(key: "ratio", indirectValue: 3.14159 + Float(i))
                        flx.add(key: "size", indirectValue: UInt(10000 + i))
                        flx.add(key: "time", indirectValue: 123456 + i)
                    }
                }
            }
        }
        flx.add(key: "location", value: "http://google.com/flatbuffers/")
    }
    return flx.finish()
}

let object = [
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
                "size" : UInt16(10000 + 0)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(0),
            "postfix" : UInt8(33 + 0)
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
                "size" : UInt16(10000 + 1)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(1),
            "postfix" : UInt8(33 + 1)
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
                "size" : UInt16(10000 + 2)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(2),
            "postfix" : UInt8(33 + 2)
        ]
    ],
    "location" : "http://google.com/flatbuffers/",
    "initialized" : true,
    "fruit" : 2
] as [String : Any]

func create() -> Data {
    return FlexBuffer.encodeInefficientButConvenient(object)
}

let object2 = [
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
                "size" : UInt16(10000 + 0)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(0),
            "postfix" : UInt8(33 + 0)
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
                "size" : UInt16(10000 + 1)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(1),
            "postfix" : UInt8(33 + 1)
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
                "size" : UInt16(10000 + 2)
            ],
            "name" : "Hello, World!",
            "rating" : 3.1415432432445543543+Double(2),
            "postfix" : UInt8(33 + 2)
        ]
    ],
    "location" : "http://google.com/flatbuffers/",
    "initialized" : true,
    "fruit" : 2
] as [String : Any]

func createJsonData() -> Data {
    return try!JSONSerialization.data(withJSONObject: object2, options: [])
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

private func use1(_ data : Data, start : Int) -> Int
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
        sum = sum &+ Int(foobar["postfix"]!.asInt!)
        sum = sum &+ Int(foobar["rating"]!.asDouble!)
        
        let bar = foobar["sibling"]!.asMap!
        
        sum = sum &+ Int(bar["ratio"]!.asFloat!)
        sum = sum &+ Int(bar["size"]!.asInt!)
        sum = sum &+ bar["time"]!.asInt!
        
        let foo = bar["parent"]!.asMap!
        sum = sum &+ foo["count"]!.asInt!
        sum = sum &+ Int(foo["id"]!.asInt!)
        sum = sum &+ Int(foo["length"]!.asInt!)
        sum = sum &+ foo["prefix"]!.asInt!
    }
    return sum
}

private func useJSON(_ data : Data, start : Int) -> Int
{
    
    var sum:Int = Int(start)
    let root = try!JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
    sum = sum &+ (root["location"] as! String).utf8.count
    sum = sum &+ (root["fruit"] as! Int)
    sum = sum &+ ((root["initialized"] as! Bool) ? 1 : 0)
    
    let list = root["list"] as! NSArray
    for i in 0..<list.count {
        let foobar = list[i] as! NSDictionary
        sum = sum &+ (foobar["name"] as! String).utf8.count
        sum = sum &+ (Int(foobar["postfix"] as! UInt))
        sum = sum &+ Int((foobar["rating"] as! Double))
        
        let bar = (foobar["sibling"] as! NSDictionary)
        
        sum = sum &+ Int((bar["ratio"] as! Float))
        sum = sum &+ Int((bar["size"] as! UInt))
        sum = sum &+ (bar["time"] as! Int)
        
        let foo = bar["parent"] as! NSDictionary
        sum = sum &+ (foo["count"] as! Int)
        sum = sum &+ Int((foo["id"] as! UInt))
        sum = sum &+ Int((foo["length"] as! UInt))
        sum = sum &+ (foo["prefix"] as! Int)
    }
    return sum
}

let NumberOfDecodings = 100_000
let NumberOfEncodings = 100_000

var datas = [Data!](repeating: nil, count: NumberOfEncodings)
var m = getMegabytesUsed()!
var d = 0.0

var t = CFAbsoluteTimeGetCurrent()

let flx = FlexBuffer(initialSize: 1, options: [])
for i in 0 ..< NumberOfEncodings {
    datas[i] = try!createContainer(flx: flx)
}
let data = datas[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("Efficient encoding (x\(NumberOfEncodings)):")
print("\(data) in \(d) \(getMegabytesUsed()! - m) MB")
m = getMegabytesUsed()!

var datas1 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas1[i] = create()
}
let data1 = datas1[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("Inefficient encoding (x\(NumberOfEncodings)):")
print("\(data1) in \(d) \(getMegabytesUsed()! - m) MB")
m = getMegabytesUsed()!



var datas2 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas2[i] = createJsonData()
}
let data2 = datas2[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("JSON encoding (x\(NumberOfEncodings)):")
print("\(data2) in \(d) \(getMegabytesUsed()! - m) MB")
m = getMegabytesUsed()!


t = CFAbsoluteTimeGetCurrent()
var sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use(data, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of efficient encoding:")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
m = getMegabytesUsed()!


t = CFAbsoluteTimeGetCurrent()
var sum1 = 0
for i in 0 ..< NumberOfDecodings {
    sum1 += use1(data1, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of inefficient encoding:")
print("\(sum1) in \(d) \(getMegabytesUsed()! - m) MB")
m = getMegabytesUsed()!



t = CFAbsoluteTimeGetCurrent()
var sum2 = 0
for i in 0 ..< NumberOfDecodings {
    sum2 += useJSON(data2, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) JSON:")
print("\(sum2) in \(d) \(getMegabytesUsed()! - m) MB")
