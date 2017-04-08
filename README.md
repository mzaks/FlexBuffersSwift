# FlexBuffersSwift
Swift implementation of FlexBuffers - a sub project of Googles FlatBuffers project [https://google.github.io/flatbuffers/].
FlexBuffers is a self suficient binary data representation which can encode numbers, strings, maps and vectors.

# Usage
```swift
// {vec:[-100,"Fred",4.0],bar:[1,2,3],bar3:[1,2,3]foo:100,mymap{foo:"Fred"}}
let flx = FlexBuffer()
flx.addMap {
    flx.addVector(key: "vec") {
        flx.add(value: -100)
        flx.add(value: "Fred")
        flx.add(value:4.0)
    }
    flx.add(key: "bar", value: [1, 2, 3])
    flx.addVector(key: "bar3") {
        flx.add(value:1)
        flx.add(value:2)
        flx.add(value:3)
    }
    flx.add(key: "foo", value: 100)
    flx.addMap(key: "mymap") {
        flx.add(key: "foo", value: "Fred")
    }
}
let data = flx.finish()

let map = FlexBuffer.decode(data: data)!.asMap!
print(map.debugDescription)
```

There is also an API for convinient encoding, which is however inefficient
```swift
let data = FlexBuffer.encodeInefficientButConvenient([
    "age" : 35,
    "flags" : [true, false, true, true],
    "weight" : 72.5,
    "address" : [
        "city" : "Bla",
        "zip" : "12345",
        "countryCode" : "XX"
    ]
])
```

FlexBuffersSwift also incorporates it's own efficient JSON parser which is used to transform JSON to FlexBuffer binary.

```
let data = FlexBuffer.dataFrom(jsonData:"{name:\"Maxim\", birthday:{\"year\": 1981, month: 6, day: 12}}".data(using: .utf8)!)
```

The binary can than be read with no parsing costs in a strong typed way:

```
let accessor = FlexBuffer.decode(data:data)
let name = accessor?["name"]?.asString
let day = accessor?["birthday"]?["day"]?.asInt
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
676 bytes in 0.90708202123642 102.34 MB
-
Inefficient FlexBuffers encoding (x100000):
938 bytes in 11.0123679637909 292.488 MB
-
JSON encoding (x100000):
657 bytes in 5.65228605270386 436.316 MB
-
FlatBuffers encoding (x100000):
352 bytes in 0.552986979484558 77.293 MB
-
FlatBuffers encoding without data duplication (x100000):
304 bytes in 0.768246948719025 72.0898 MB
-
FlexBuffers encoding from JSON string (x100000):
704 bytes in 2.01514601707458 159.973 MB
-------------
Decoding (x100000) result of efficient FlexBuffers encoding:
864436166550000 in 0.332314014434814 1.57031 MB
-
Decoding (x100000) result of efficient FlexBuffers encoding and using access chaining:
864436166550000 in 0.525431036949158 1.55469 MB
-
Decoding (x100000) result of inefficient FlexBuffers encoding:
864436166550000 in 0.308874011039734 1.55469 MB
-
Decoding (x100000) JSON:
864436166550000 in 4.90053498744965 235.762 MB
-
Decoding (x100000) FlatBuffers:
864436166550000 in 0.0180090069770813 0.0078125 MB
-
Decoding FlexBuffers created from JSON string (x100000):
864436166550000 in 0.318319022655487 1.48828 MB
```
