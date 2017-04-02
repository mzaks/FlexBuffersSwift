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

# Performance
The strength of FlexBuffers is that it supports random data access without need of upfront parsing or any kind of data interpretation.
But even when all data has to be accessed it runs about 15 times more performant than JSON.
Please have a look at `FlexBuffersPerformanceTest` target.

Results on MBP Retina 2015
2,8 GHz Intel Core i7
16 GB 1600 MHz DDR3

```
Efficient encoding (x100000):
676 bytes in 0.891993999481201 102.602 MB
Inefficient encoding (x100000):
938 bytes in 11.3335829973221 292.504 MB
JSON encoding (x100000):
657 bytes in 5.58083403110504 436.199 MB
Decoding (x100000) result of efficient encoding:
864436166550000 in 0.301067054271698 1.55469 MB
Decoding (x100000) result of inefficient encoding:
864436166550000 in 0.294642984867096 1.55078 MB
Decoding (x100000) JSON:
864436166550000 in 4.53991097211838 235.773 MB
```
