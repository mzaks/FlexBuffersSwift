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
    try!flx.addMap {
        flx.add(key: "fruit", value:2)
        flx.add(key: "initialized", value:true)
        try!flx.addVector(key:"list") {
            for i in 0..<3 {
                let ident : UInt64 = 0xABADCAFE + UInt64(i)
                try!flx.addMap {
                    flx.add(key: "name", value: "Hello, World!")
                    flx.add(key: "postfix", value: UInt(33 + i))
                    try!flx.add(key: "rating" , indirectValue: 3.1415432432445543543+Double(i))
                    try!flx.addMap(key:"sibling") {
                        try!flx.addMap(key:"parent") {
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
    return try!flx.finish()
}

func createContainerWithBuilder() throws -> Data {
    return try FlexBufferBuilder.encodeMap{
        $0.add("fruit", 2)
        $0.add("initialized", true)
        $0.addVector("list"){
            for i in 0..<3 {
                let ident : UInt64 = 0xABADCAFE + UInt64(i)
                $0.addMap {
                    $0.add("name","Hello, World!")
                    $0.add("postfix", UInt(33 + i))
                    $0.indirectAdd("rating" , 3.1415432432445543543+Double(i))
                    $0.addMap("sibling") {
                        $0.addMap("parent") {
                            $0.indirectAdd("count",10000 + i)
                            $0.indirectAdd("id", ident)
                            $0.indirectAdd("length", UInt(1000000 + i))
                            $0.add("prefix", 64 + i)
                        }
                        $0.indirectAdd("ratio", Double(3.14159 + Float(i)))
                        $0.indirectAdd("size", UInt(10000 + i))
                        $0.indirectAdd("time", 123456 + i)
                    }
                }
            }
        }
        $0.add("location", "http://google.com/flatbuffers/")
    }.data
}


let parent0 = [
    "id" : 0xABADCAFE + 0,
    "count" : 10000 + 0,
    "prefix" : 64 + 0,
    "length" : 1000000 + 0
    ] as FlxbValueMap
let parent1 = [
    "id" : 0xABADCAFE + 1,
    "count" : 10000 + 1,
    "prefix" : 64 + 1,
    "length" : 1000000 + 1
    ] as FlxbValueMap
let parent2 = [
    "id" : 0xABADCAFE + 2,
    "count" : 10000 + 2,
    "prefix" : 64 + 2,
    "length" : 1000000 + 2
    ] as FlxbValueMap

let sibling0  = [
    "parent" : parent0,
    "time" : 123456 + 0,
    "ratio" : 3.14159 + 0,
    "size" : 10000 + 0
    ] as FlxbValueMap
let sibling1  = [
    "parent" : parent1,
    "time" : 123456 + 1,
    "ratio" : 3.14159 + 1,
    "size" : 10000 + 1
    ] as FlxbValueMap
let sibling2  = [
    "parent" : parent2,
    "time" : 123456 + 2,
    "ratio" : 3.14159 + 2,
    "size" : 10000 + 2
    ] as FlxbValueMap
let listItem0 = [
        "sibling": sibling0,
        "name": "Hello, World!" as StaticString,
        "rating" : 3.1415432432445543543+0,
        "postfix" : UInt(33 + 0)
    ] as FlxbValueMap
let listItem1 = [
    "sibling": sibling1,
    "name": "Hello, World!" as StaticString,
    "rating" : 3.1415432432445543543+1,
    "postfix" : UInt(33 + 1)
    ] as FlxbValueMap
let listItem2 = [
    "sibling": sibling2,
    "name": "Hello, World!" as StaticString,
    "rating" : 3.1415432432445543543+2,
    "postfix" : UInt(33 + 2)
    ] as FlxbValueMap
let object = [
    "list": [listItem0, listItem1, listItem2] as FlxbValueVector,
    "location" : "http://google.com/flatbuffers/" as StaticString,
    "initialized" : true,
    "fruit" : 2
    ] as FlxbValueMap

func create() -> Data {
    return try!FlexBuffer.encode(object).data
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

let jsonStringData = "{\"fruit\" : 2, \"initialized\" : true, \"list\" : [{\"name\" : \"Hello, World!\", \"postfix\" : 33, \"rating\" : 3.14154, \"sibling\" : {\"parent\" : {\"count\" : 10000, \"id\" : 2880293630, \"length\" : 1000000, \"prefix\" : 64}, \"ratio\" : 3.14159, \"size\" : 10000, \"time\" : 123456}}, {\"name\" : \"Hello, World!\", \"postfix\" : 34, \"rating\" : 4.14154, \"sibling\" : {\"parent\" : {\"count\" : 10001, \"id\" : 2880293631, \"length\" : 1000001, \"prefix\" : 65}, \"ratio\" : 4.14159, \"size\" : 10001, \"time\" : 123457}}, {\"name\" : \"Hello, World!\", \"postfix\" : 35, \"rating\" : 5.14154, \"sibling\" : {\"parent\" : {\"count\" : 10002, \"id\" : 2880293632, \"length\" : 1000002, \"prefix\" : 66}, \"ratio\" : 5.14159, \"size\" : 10002, \"time\" : 123458}}], \"location\" : \"http://google.com/flatbuffers/\"}".data(using: .utf8)

let jsonStringUnsortedData = "{\"list\":[{\"name\":\"Hello, World!\",\"postfix\":33,\"rating\":3.141543243244554,\"sibling\":{\"size\":10000,\"ratio\":3.14159,\"time\":123456,\"parent\":{\"prefix\":64,\"length\":1000000,\"id\":2880293630,\"count\":10000}}},{\"name\":\"Hello, World!\",\"postfix\":34,\"rating\":4.141543243244554,\"sibling\":{\"size\":10001,\"ratio\":4.14159,\"time\":123457,\"parent\":{\"prefix\":65,\"length\":1000001,\"id\":2880293631,\"count\":10001}}},{\"name\":\"Hello, World!\",\"postfix\":35,\"rating\":5.141543243244554,\"sibling\":{\"size\":10002,\"ratio\":5.14159,\"time\":123458,\"parent\":{\"prefix\":66,\"length\":1000002,\"id\":2880293632,\"count\":10002}}}],\"initialized\":true,\"location\":\"http:\\/\\/google.com\\/flatbuffers\\/\",\"fruit\":2}".data(using: .utf8)


func createFlexBufferFromJsonString() -> FlxbData {
    return try!FlexBuffer.dataFrom(jsonData: jsonStringData!, initialSize: 800, options: [])
}

func createFlatBufferContainer() -> Data {
    let veclen = 3
    var foobars = [FooBar](repeating: FooBar(), count: veclen)
    
    for i in 0..<veclen { // 0xABADCAFEABADCAFE will overflow in usage
        let ident : UInt64 = 0xABADCAFE + UInt64(i)
        let foo = Foo(id: ident, count: 10000 + Int16(i), prefix: 64 + Int8(i), length: UInt32(1000000 + i))
        let bar = Bar(parent: foo, time: 123456 + Int32(i), ratio: 3.14159 + Float(i), size: UInt16(10000 + i))
        let name = "Hello, World!"
        let foobar = FooBar(sibling: bar, name: name, rating: 3.1415432432445543543+Double(i), postfix: UInt8(33 + i))
        foobars[i] = foobar
    }
    
    let location = "http://google.com/flatbuffers/"
    let foobarcontainer = FooBarContainer(list: foobars, initialized: true, fruit: Enum.Bananas, location: location)
    
    return try!foobarcontainer.makeData(withOptions: FlatBuffersBuilderOptions(initialCapacity: 380, uniqueStrings: false, uniqueTables: false, uniqueVTables: false, forceDefaults: false, nullTerminatedUTF8: true))
}

func createFlatBufferContainerWithoutDataDuplication() -> Data {
    let veclen = 3
    var foobars = [FooBar](repeating: FooBar(), count: veclen)
    
    for i in 0..<veclen { // 0xABADCAFEABADCAFE will overflow in usage
        let ident : UInt64 = 0xABADCAFE + UInt64(i)
        let foo = Foo(id: ident, count: 10000 + Int16(i), prefix: 64 + Int8(i), length: UInt32(1000000 + i))
        let bar = Bar(parent: foo, time: 123456 + Int32(i), ratio: 3.14159 + Float(i), size: UInt16(10000 + i))
        let name = "Hello, World!"
        let foobar = FooBar(sibling: bar, name: name, rating: 3.1415432432445543543+Double(i), postfix: UInt8(33 + i))
        foobars[i] = foobar
    }
    
    let location = "http://google.com/flatbuffers/"
    let foobarcontainer = FooBarContainer(list: foobars, initialized: true, fruit: Enum.Bananas, location: location)
    
    return try!foobarcontainer.makeData(withOptions: FlatBuffersBuilderOptions(initialCapacity: 380, uniqueStrings: true, uniqueTables: true, uniqueVTables: true, forceDefaults: false, nullTerminatedUTF8: true))
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
        sum = sum &+ Int(foobar["postfix"]!.asUInt!)
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

private func use2(_ data : Data, start : Int) -> Int
{
    var sum:Int = Int(start)
    let root = FlexBuffer.decode(data: data)!
    
    sum = sum &+ root["location"]!.asString!.utf8.count
    sum = sum &+ root["fruit"]!.asInt!
    sum = sum &+ (root["initialized"]!.asBool! ? 1 : 0)
    
    let list = root["list"]!.asVector!
    for i in 0..<list.count {
        sum = sum &+ root["list"]![i]!["name"]!.asString!.utf8.count
        sum = sum &+ Int(root["list"]![i]!["postfix"]!.asUInt!)
        sum = sum &+ Int(root["list"]![i]!["rating"]!.asDouble!)
        
        sum = sum &+ Int(root["list"]![i]!["sibling"]!["ratio"]!.asFloat!)
        sum = sum &+ Int(root["list"]![i]!["sibling"]!["size"]!.asUInt!)
        sum = sum &+ root["list"]![i]!["sibling"]!["time"]!.asInt!
        
        sum = sum &+ root["list"]![i]!["sibling"]!["parent"]!["count"]!.asInt!
        sum = sum &+ Int(root["list"]![i]!["sibling"]!["parent"]!["id"]!.asUInt!)
        sum = sum &+ Int(root["list"]![i]!["sibling"]!["parent"]!["length"]!.asUInt!)
        sum = sum &+ root["list"]![i]!["sibling"]!["parent"]!["prefix"]!.asInt!
    }
    return sum
}

private func use3(_ data : Data, start : Int) -> Int
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
        
        sum = sum &+ Int(bar["ratio"]!.asDouble!)
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

private func use3(_ reader : FlatBuffersMemoryReader, start : Int) -> Int
{
    var sum:Int = Int(start)
    let foobarcontainer = FooBarContainer_Direct(reader)!
    
    sum = sum &+ Int(foobarcontainer.location!.count)
    sum = sum &+ Int(foobarcontainer.fruit!.rawValue)
    sum = sum &+ (foobarcontainer.initialized ? 1 : 0)
    
    for i in 0..<foobarcontainer.list.count {
        let foobar = foobarcontainer.list[i]!
        sum = sum &+ Int(foobar.name!.count)
        sum = sum &+ Int(foobar.postfix)
        sum = sum &+ Int(foobar.rating)
        
        let bar = foobar.sibling!
        
        sum = sum &+ Int(bar.ratio)
        sum = sum &+ Int(bar.size)
        sum = sum &+ Int(bar.time)
        
        let foo = bar.parent
        sum = sum &+ Int(foo.count)
        sum = sum &+ Int(foo.id)
        sum = sum &+ Int(foo.length)
        sum = sum &+ Int(foo.prefix)
    }
    return sum
}

private func use4(_ data : Data, start : Int) -> Int
{
    let flxData = try!FlexBuffer.dataFrom(jsonData: data)
    var sum:Int = Int(start)
    let root = flxData.root!.asMap!
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
        
        sum = sum &+ Int(bar["ratio"]!.asDouble!)
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




let NumberOfDecodings = 100_000
let NumberOfEncodings = 100_000

var datas = [Data!](repeating: nil, count: NumberOfEncodings)
var m = getMegabytesUsed()!
var d = 0.0

var t = CFAbsoluteTimeGetCurrent()

let flx = FlexBuffer(initialSize: 1024, options: [])
for i in 0 ..< NumberOfEncodings {
    datas[i] = try!createContainer(flx: flx)
}
let data = datas[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("Efficient FlexBuffers encoding (x\(NumberOfEncodings)):")
print("\(data) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

var datas_ = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas_[i] = try!createContainerWithBuilder()
}
let data_ = datas_[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("FlexBuffers encoding with Builder (x\(NumberOfEncodings)):")
print("\(data_) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

var datas1 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas1[i] = create()
}
let data1 = datas1[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("Convinient FlexBuffers encoding (x\(NumberOfEncodings)):")
print("\(data1) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

var datas5 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas5[i] = createFlexBufferFromJsonString().data
}
let data5 = datas5[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("FlexBuffers encoding from JSON string (x\(NumberOfEncodings)):")
print("\(data5) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
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
print("-")
m = getMegabytesUsed()!

var datas0 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
let flx0 = FlexBuffer(initialSize: 1024, options: [])
for i in 0 ..< NumberOfEncodings {
    datas0[i] = FlxbData(data:try!createContainer(flx: flx0)).root!.jsonString.data(using: .utf8)
}
let data0 = datas0[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("Efficient FlexBuffers encoding to JSON string (x\(NumberOfEncodings)):")
print("\(data0) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

var datas3 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas3[i] = createFlatBufferContainer()
}
let data3 = datas3[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("FlatBuffers encoding (x\(NumberOfEncodings)):")
print("\(data3) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

var datas4 = [Data!](repeating: nil, count: NumberOfEncodings)
t = CFAbsoluteTimeGetCurrent()
for i in 0 ..< NumberOfEncodings {
    datas4[i] = createFlatBufferContainerWithoutDataDuplication()
}
let data4 = datas4[0]!
d = CFAbsoluteTimeGetCurrent() - t
print("FlatBuffers encoding without data duplication (x\(NumberOfEncodings)):")
print("\(data4) in \(d) \(getMegabytesUsed()! - m) MB")
print("-------------")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
var sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use(data, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of efficient FlexBuffers encoding:")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use(data_, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of efficient FlexBuffers encoding with Builder:")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!


t = CFAbsoluteTimeGetCurrent()
sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use2(data, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of efficient FlexBuffers encoding and using access chaining:")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!


t = CFAbsoluteTimeGetCurrent()
var sum1 = 0
for i in 0 ..< NumberOfDecodings {
    sum1 += use1(data1, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) result of convinient FlexBuffers encoding:")
print("\(sum1) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
var sum2 = 0
for i in 0 ..< NumberOfDecodings {
    sum2 += useJSON(data2, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) JSON:")
print("\(sum2) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
var sum3 = 0
let reader = FlatBuffersMemoryReader(data: data3)
for i in 0 ..< NumberOfDecodings {
    sum3 += use3(reader, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding (x\(NumberOfDecodings)) FlatBuffers:")
print("\(sum3) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use3(data5, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding FlexBuffers created from JSON string (x\(NumberOfDecodings)):")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use4(jsonStringData!, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding JSON by encoding it to FlexBuffers and than using it (x\(NumberOfDecodings)):")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!

t = CFAbsoluteTimeGetCurrent()
sum = 0
for i in 0 ..< NumberOfDecodings {
    sum += use4(jsonStringUnsortedData!, start: i)
}
d = CFAbsoluteTimeGetCurrent() - t
print("Decoding unsorted JSON by encoding it to FlexBuffers and than using it (x\(NumberOfDecodings)):")
print("\(sum) in \(d) \(getMegabytesUsed()! - m) MB")
print("-")
m = getMegabytesUsed()!
