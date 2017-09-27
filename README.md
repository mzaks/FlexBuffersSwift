# FlexBuffersSwift
[![Build Status](https://travis-ci.org/mzaks/FlexBuffersSwift.svg?branch=master)](https://travis-ci.org/mzaks/FlexBuffersSwift)[![codecov](https://codecov.io/gh/mzaks/FlexBuffersSwift/branch/master/graph/badge.svg)](https://codecov.io/gh/mzaks/FlexBuffersSwift)[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Swift implementation of FlexBuffers - a sub project of Googles FlatBuffers project [https://google.github.io/flatbuffers/].
FlexBuffers is a self suficient binary data representation which can encode numbers, strings, maps and vectors.

# Usage
Following blog post describes the usage in great detail:
https://medium.com/@icex33/flexbuffersswift-9546bb217aeb

Less detailed discripiton can be found below.

---

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

let map = FlxbData(data: data)
print(map.debugDescription)
```

There is an API for convinient encoding:
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

FlexBuffersSwift incorporates it's own efficient JSON parser which is used to transform JSON to FlexBuffer binary.

```
let flxbData = try!FlexBuffer.dataFrom(jsonData:"{name:\"Maxim\", birthday:{\"year\": 1981, month: 6, day: 12}}".data(using: .utf8)!)
```

The binary can be read with no parsing costs in a strong typed way:

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
676 bytes in 1.0978490114212 106.336 MB
-
FlexBuffers encoding with Builder (x100000):
676 bytes in 1.28725802898407 75.6953 MB
-
Convinient FlexBuffers encoding (x100000):
1010 bytes in 2.00599104166031 107.188 MB
-
FlexBuffers encoding from JSON string (x100000):
704 bytes in 2.08162301778793 79.3438 MB
-
JSON encoding (x100000):
657 bytes in 6.31411296129227 442.465 MB
-
Efficient FlexBuffers encoding to JSON string (x100000):
654 bytes in 1.30120497941971 23.7539 MB
-
FlatBuffers encoding (x100000):
352 bytes in 0.437988996505737 83.7344 MB
-
FlatBuffers encoding without data duplication (x100000):
304 bytes in 0.568202972412109 75.7031 MB
-------------
Decoding (x100000) result of efficient FlexBuffers encoding:
864436166550000 in 0.311857998371124 0.00390625 MB
-
Decoding (x100000) result of efficient FlexBuffers encoding with Builder:
864436166550000 in 0.309445977210999 0.00390625 MB
-
Decoding (x100000) result of efficient FlexBuffers encoding and using access chaining:
864436166550000 in 0.609730005264282 0.00390625 MB
-
Decoding (x100000) result of convinient FlexBuffers encoding:
864436166550000 in 0.321048974990845 0.00390625 MB
-
Decoding (x100000) JSON:
864436166550000 in 3.66075402498245 167.09 MB
-
Decoding (x100000) FlatBuffers:
864436166550000 in 0.0174689888954163 0.0078125 MB
-
Decoding FlexBuffers created from JSON string (x100000):
864436166550000 in 0.32822197675705 0.00390625 MB
-
Decoding JSON by encoding it to FlexBuffers and than using it (x100000):
864436166550000 in 2.41890394687653 1.46094 MB
-
Decoding unsorted JSON by encoding it to FlexBuffers and than using it (x100000):
864436166550000 in 2.49017596244812 1.44531 MB
-
```
