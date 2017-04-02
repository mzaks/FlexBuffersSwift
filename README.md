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
676 bytes in 0.869431972503662 102.582 MB
-
Inefficient encoding (x100000):
938 bytes in 10.5983529686928 292.504 MB
-
JSON encoding (x100000):
657 bytes in 5.62160700559616 436.246 MB
-
FlatBuffers encoding (x100000):
352 bytes in 0.542607009410858 77.3203 MB
-
FlatBuffers encoding without data duplication (x100000):
304 bytes in 0.733329951763153 72.0781 MB
-------------
Decoding (x100000) result of efficient encoding:
864436166550000 in 0.300754010677338 1.55859 MB
-
Decoding (x100000) result of inefficient encoding:
864436166550000 in 0.312528014183044 1.55469 MB
-
Decoding (x100000) JSON:
864436166550000 in 4.79045802354813 235.758 MB
-
Decoding (x100000) FlatBuffers:
864436166550000 in 0.0172100067138672 0.0117188 MB
```
