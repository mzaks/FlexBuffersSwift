# FlexBuffersSwift
[![Build Status](https://travis-ci.org/mzaks/FlexBuffersSwift.svg?branch=master)](https://travis-ci.org/mzaks/FlexBuffersSwift)[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Swift implementation of FlexBuffers - a sub project of Googles FlatBuffers project [https://google.github.io/flatbuffers/].
FlexBuffers is a self suficient binary data representation which can encode numbers, strings, maps and vectors.

# Usage
```swift
// {vec:[-100,"Fred",4.0], bar:[1,2,3], bar3:[1,2,3], foo:100, mymap:{foo:"Fred"}}
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
    try!flx.add(key: "foo", value: 100)
    try!flx.addMap(key: "mymap") {
        flx.add(key: "foo", value: "Fred")
    }
}
let data = flx.finish()

let map = try!FlexBuffer.decode(data: data)!.asMap!
print(map.debugDescription)
```

There is also an API for convinient encoding:
```swift
let flxbData = try!FlexBuffer.encode([
    "age" : 35,
    "flags" : [true, false, true, true] as FlxbValueVector,
    "weight" : 72.5,
    "address" : [
        "city" : "Bla",
        "zip" : "12345",
        "countryCode" : "XX"
    ] as FlxbValueMap
] as FlxbValueMap)
```

FlexBuffersSwift also incorporates it's own efficient JSON parser which is used to transform JSON to FlexBuffer binary.

```
let flxbData = try!FlexBuffer.dataFrom(jsonData:"{name:\"Maxim\", birthday:{\"year\": 1981, month: 6, day: 12}}".data(using: .utf8)!)
```

The binary can than be read with no parsing costs in a strong typed way:

```
let root = flxbData.root
let name = root?["name"]?.asString
let day = root?["birthday"]?["day"]?.asInt
```

Or you can turn the binary back to JSON string

```
print(root!.jsonString)
```

# Performance
The strength of FlexBuffers is that it supports random data access without need of upfront parsing or any kind of data interpretation.
But even when all data has to be accessed it runs about 15 times more performant than JSON.
Please have a look at `FlexBuffersPerformanceTest` target.

Results on MBP Retina 2015
2,8 GHz Intel Core i7
16 GB 1600 MHz DDR3

```
Efficient FlexBuffers encoding (x100000):
676 bytes in 0.974463999271393 106.312 MB
-
Efficient FlexBuffers encoding to JSON string (x100000):
654 bytes in 2.22512096166611 27.9219 MB
-
Convinient FlexBuffers encoding (x100000):
1010 bytes in 1.60217899084091 105.129 MB
-
JSON encoding (x100000):
657 bytes in 6.67863005399704 444.391 MB
-
FlatBuffers encoding (x100000):
352 bytes in 0.441623032093048 84.5078 MB
-
FlatBuffers encoding without data duplication (x100000):
304 bytes in 0.54592502117157 75.3828 MB
-
FlexBuffers encoding from JSON string (x100000):
704 bytes in 1.80597501993179 79.0039 MB
-------------
Decoding (x100000) result of efficient FlexBuffers encoding:
864436166550000 in 0.270677983760834 0.0 MB
-
Decoding (x100000) result of efficient FlexBuffers encoding and using access chaining:
864436166550000 in 0.469451010227203 0.0078125 MB
-
Decoding (x100000) result of convinient FlexBuffers encoding:
864436166550000 in 0.268750011920929 0.00390625 MB
-
Decoding (x100000) JSON:
864436166550000 in 3.85789197683334 163.832 MB
-
Decoding (x100000) FlatBuffers:
864436166550000 in 0.017283022403717 0.0078125 MB
-
Decoding FlexBuffers created from JSON string (x100000):
864436166550000 in 0.271202027797699 0.0078125 MB
-
Decoding JSON by encoding it to FlexBuffers and than using it (x100000):
864436166550000 in 2.09489101171494 1.49609 MB
-
Decoding unsorted JSON by encoding it to FlexBuffers and than using it (x100000):
864436166550000 in 2.1292319893837 1.55469 MB
-
```
