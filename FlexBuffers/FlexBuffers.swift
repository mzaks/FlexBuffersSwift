//
//  FlexBuffers.swift
//  FlexBuffers
//
//  Created by Maxim Zaks on 27.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import Foundation

fileprivate enum BitWidth : UInt8 {
    case width8, width16, width32, width64
    static func width(uint : UInt64) -> BitWidth {
        if (uint & 0xFFFFFFFFFFFFFF00) == 0 {
            return .width8
        }
        if (uint & 0xFFFFFFFFFFFF0000) == 0 {
            return .width16
        }
        if (uint & 0xFFFFFFFF00000000) == 0 {
            return .width32
        }
        return .width64
    }
    
    static func width(int : Int64) -> BitWidth {
        let u = UInt64(bitPattern: int) << 1
        return width(uint: int >= 0 ? u : ~u)
    }
    static func width(double : Double) -> BitWidth {
        if Double(Float32(double)) == double {
            return .width32
        }
        return width64
    }
}

fileprivate enum Type : UInt8 {
    case null, int, uint, float,
    key, string, indirect_int, indirect_uint, indirect_float,
    map, vector, vector_int, vector_uint, vector_float, vector_key,
    vector_int2, vector_uint2, vector_float2,
    vector_int3, vector_uint3, vector_float3,
    vector_int4, vector_uint4, vector_float4,
    blob
    
    var isInline : Bool {
        return self.rawValue <= Type.float.rawValue
    }
    
    var isTypedVectorElement : Bool {
        return self.rawValue >= Type.int.rawValue && self.rawValue <= Type.key.rawValue
    }
    
    var isTypedVector : Bool {
        return self.rawValue >= Type.vector_int.rawValue && self.rawValue <= Type.vector_key.rawValue
    }
    
    func toTypedVector(length : UInt8 = 0) -> Type {
        switch length {
        case 0:
            return Type(rawValue: self.rawValue - Type.int.rawValue + Type.vector_int.rawValue) ?? Type.null
        case 2:
            return Type(rawValue: self.rawValue - Type.int.rawValue + Type.vector_int2.rawValue) ?? Type.null
        case 3:
            return Type(rawValue: self.rawValue - Type.int.rawValue + Type.vector_int3.rawValue) ?? Type.null
        case 4:
            return Type(rawValue: self.rawValue - Type.int.rawValue + Type.vector_int4.rawValue) ?? Type.null
        default:
            assertionFailure()
            return Type.null
        }
    }
    
    var typedVectorElementType : Type {
        return Type(rawValue: self.rawValue - Type.vector_int.rawValue + Type.int.rawValue) ?? Type.null
    }
    
    var isFixedTypedVector : Bool {
        return self.rawValue >= Type.vector_int2.rawValue && self.rawValue <= Type.vector_float4.rawValue
    }
    
    var fixedTypedVectorElementType : (type : Type, length : UInt8) {
        let fixedType = self.rawValue - Type.vector_int2.rawValue
        let length = fixedType / 3 + 2
        let type = Type(rawValue: fixedType % 3 + Type.int.rawValue) ?? Type.null
        return (type: type, length: length)
    }
}

private func packedType(width : BitWidth, type : Type) -> UInt8 {
    return width.rawValue | (type.rawValue << 2)
}

private func nullPackedType() -> UInt8 {
    return packedType(width: .width8, type: .null)
}

private func paddingSize(bufSize : Int, scalarSize : UInt8) -> Int {
    return ((~bufSize) + 1) & (Int(scalarSize) - 1)
}

public struct BuilderOptions : OptionSet {
    public let rawValue: UInt8
    public static let shareKeys = BuilderOptions(rawValue:1 << 0)
    public static let shareStrings = BuilderOptions(rawValue:1 << 1)
    public static let shareKeyVectors = BuilderOptions(rawValue:1 << 2)
    public static let shareKeysAndStrings : BuilderOptions = [.shareKeys, .shareStrings]
    public static let shareAll : BuilderOptions = [.shareKeys, .shareStrings, .shareKeyVectors]
    
    public init(rawValue : UInt8) {
        self.rawValue = rawValue
    }
}

enum FlexBufferEncodeError: Error {
    case unexpectedType
}

public class FlexBuffer {
    
    public func addNull(){
        null()
    }
    
    public func addValue<T : FlxbValue>(_ v : T){
        switch v {
        case let v as Bool:
            bool(v)
        case let v as UnsignedInteger:
            uint(v.toUIntMax())
        case let v as SignedInteger:
            int(v.toIntMax())
        case let v as Float:
            float(v)
        case let v as Double:
            double(v)
        case let v as String:
            string(v)
        default:
            assertionFailure("Unexpected FlxValue type added \(type(of: v))")
            break
        }
    }
    
    public func addValue<T : FlxbValue>(keyString : String, value : T){
        self.key(keyString)
        switch value {
        case let v as Bool:
            bool(v)
        case let v as UnsignedInteger:
            uint(v.toUIntMax())
        case let v as SignedInteger:
            int(v.toIntMax())
        case let v as Float:
            float(v)
        case let v as Double:
            double(v)
        case let v as String:
            string(v)
        default:
            assertionFailure("Unexpected FlxValue type added \(type(of: value))")
            break
        }
    }
    public func addValue<T : FlxbValue>(key : StaticString, value : T){
        self.key(key)
        switch value {
        case let v as Bool:
            bool(v)
        case let v as UnsignedInteger:
            uint(v.toUIntMax())
        case let v as SignedInteger:
            int(v.toIntMax())
        case let v as Float:
            float(v)
        case let v as Double:
            double(v)
        case let v as String:
            string(v)
        default:
            assertionFailure("Unexpected FlxValue type added \(type(of: value))")
            break
        }
    }
    
    public func addArray<T : FlxbScalarValue>(_ vs : [T]){
        let start = startVector()
        for v in vs {
            addValue(v)
        }
        _ = endVector(start: start, typed: true, fixed: false)
    }
    
    public func untypedVector(_ array : NSArray){
        let start = startVector()
        for v in array {
            handleValue(v)
        }
        _ = endVector(start: start, typed: false, fixed: false)
    }
    
    public func untypedMap(_ dict : NSDictionary){
        let start = startMap()
        for v in dict {
            if let key = v.key as? String {
                self.key(key)
            }
            handleValue(v.value)
        }
        endMap(start: start)
    }
    
    fileprivate func handleValue(_ v : Any){
        switch v {
        case let v as Bool:
            bool(v)
        case let v as UnsignedInteger:
            uint(v.toUIntMax())
        case let v as SignedInteger:
            int(v.toIntMax())
        case let v as UInt:     // because of NSNumber I suppose :(
            uint(UIntMax(v))
        case let v as Int:      // because of NSNumber I suppose :(
            int(IntMax(v))
        case let v as Float:
            float(v)
        case let v as Double:
            double(v)
        case let v as String:
            string(v)
        case let v as NSNumber:      // because of NSNumber I suppose :(
            int(IntMax(v))
        case let v as NSDictionary:
            untypedMap(v)
        case let v as NSArray:
            untypedVector(v)
        case _ as NSNull:
            addNull()
        default:
            assertionFailure("Unexpected FlxValue type added \(type(of: v))")
            break
        }

    }
    
    public func addVector(_ f : ()->()){
        let start = startVector()
        f()
        _ = endVector(start: start, typed: false, fixed: false)
    }
    
    public func addVector(key : StaticString, _ f : ()->()){
        self.key(key)
        let start = startVector()
        f()
        _ = endVector(start: start, typed: false, fixed: false)
    }
    
    public func addVector(keyString : String, _ f : ()->()){
        self.key(keyString)
        let start = startVector()
        f()
        _ = endVector(start: start, typed: false, fixed: false)
    }
    
    public func addMap(_ f : ()->()){
        let start = startMap()
        f()
        endMap(start: start)
    }
    
    public func addMap(key : StaticString, _ f : ()->()){
        self.key(key)
        let start = startMap()
        f()
        endMap(start: start)
    }
    
    public func addMap(keyString : String, _ f : ()->()){
        self.key(keyString)
        let start = startMap()
        f()
        endMap(start: start)
    }
    
    fileprivate struct Value {
        enum Container {
            case int(Int64)
            case uint(UInt64)
            case double(Double)
            var asInt : Int64 {
                switch self {
                case let .int(value):
                    return Int64(value)
                case let .uint(value):
                    return Int64(value)
                case let .double(value):
                    return Int64(value)
                }
            }
            var asUInt : UInt64 {
                switch self {
                case let .int(value):
                    return UInt64(value)
                case let .uint(value):
                    return UInt64(value)
                case let .double(value):
                    return UInt64(value)
                }
            }
            var asDouble : Double {
                switch self {
                case let .int(value):
                    return Double(value)
                case let .uint(value):
                    return Double(value)
                case let .double(value):
                    return Double(value)
                }
            }
        }
        let value : Container
        let type : Type
        let minBitWidth : BitWidth
        init() {
            value = Value.Container.int(0)
            type = .null
            minBitWidth = .width8
        }
        init(value : Int64, type : Type, bitWidth : BitWidth) {
            self.value = Value.Container.int(value)
            self.type = type
            minBitWidth = bitWidth
        }
        
        init(value : UInt64, type : Type, bitWidth : BitWidth) {
            self.value = Value.Container.uint(value)
            self.type = type
            minBitWidth = bitWidth
        }
        
        init(value : Float) {
            self.value = Value.Container.double(Double(value))
            self.type = .float
            minBitWidth = .width32
        }
        
        init(value : Double) {
            self.value = Value.Container.double(value)
            self.type = .float
            minBitWidth = BitWidth.width(double: value)
        }
        
        func storedWidth(bitWidth : BitWidth = .width8) -> BitWidth {
            if type.isInline {
                return BitWidth(rawValue: max(minBitWidth.rawValue, bitWidth.rawValue))!
            }
            return minBitWidth
        }
        
        func storedPackedType(width : BitWidth = .width8) -> UInt8 {
            return packedType(width: storedWidth(bitWidth: width), type: type)
        }
        
        func elementWidth(size : Int, index : Int) -> BitWidth {
            if type.isInline {
                return minBitWidth
            } else {
                // TODO: Ask Wouter
                for width in [UInt8(1), UInt8(2), UInt8(4), UInt8(8)] {
                    let offset_loc = size + paddingSize(bufSize: size, scalarSize: width) + index * Int(width)
                    let offset = offset_loc - Int(value.asInt)
                    let bit_width = BitWidth.width(int: Int64(offset))
                    if (1 << bit_width.rawValue) == UInt8(width) {
                        return bit_width
                    }
                }
                assertionFailure("Must match one of the sizes above.")
                return .width64
            }
        }
        
        
    }
    
    let initialSize : Int
    let options : BuilderOptions
    var finished = false
    var buffer : [UInt8]
    private var stack : [Value] = []
    var keyPool : [String:Int] = [:]
    var stringPool : [String:Int] = [:]
    
    init(initialSize : Int = 256, options : BuilderOptions = []) {
        self.initialSize = initialSize
        self.options = options
        buffer = []
    }
    
    func null() {
        stack.append(Value())
    }
    
    func int(_ i : IntMax) {
        stack.append(Value(value: Int64(i), type: .int, bitWidth: BitWidth.width(int: Int64(i))))
    }
    
    func uint(_ i : UIntMax) {
        stack.append(Value(value: UInt64(i), type: .uint, bitWidth: BitWidth.width(uint: UInt64(i))))
    }
    
    func float(_ f : Float) {
        stack.append(Value(value: f))
    }
    
    func double(_ d : Double) {
        stack.append(Value(value: d))
    }
    
    func bool(_ b : Bool) {
        b ? int(1) : int(0)
    }
    
    func string(_ s : String) {
//        let chars = s.utf8CString.map({UInt8($0)})
//        createBlob(data: chars, length: chars.count - 1, trailing: 1, type: .string)
        
        let chars = s.utf8CString
        let length = chars.count - 1
        let bitWidth = BitWidth.width(uint: UInt64(length))
        let byteWidth = align(width: bitWidth)
        write(value: length, size: byteWidth)
        let sloc = buffer.count
        for c in chars {
            self.buffer.append(UInt8(c))
        }
        stack.append(Value(value: UInt64(sloc), type: .string, bitWidth: bitWidth))
    }
    
    fileprivate func key(_ s : String) {
        let sloc : Int
        if options.contains(.shareKeys), let index = keyPool[s] {
            sloc = index
        } else {
            sloc = buffer.count
            for c in s.utf8CString {
                self.buffer.append(UInt8(c))
            }
            if options.contains(.shareKeys) {
                keyPool[s] = sloc
            }
        }
        
        stack.append(Value(value: UInt64(sloc), type: .key, bitWidth: .width8))
    }
    
    fileprivate func key(_ s : StaticString) {
        let sd = s.description
        let sloc : Int
        if options.contains(.shareKeys), let index = keyPool[sd] {
            sloc = index
        } else {
            sloc = buffer.count
            s.withUTF8Buffer {
                for c in $0 {
                    buffer.append(c)
                }
                self.buffer.append(0)
            }
            if options.contains(.shareKeys) {
                keyPool[sd] = sloc
            }
        }
        
        stack.append(Value(value: UInt64(sloc), type: .key, bitWidth: .width8))
    }
    
    fileprivate func pushIndirect<T : FlxbBigScalarValue>(_ val : T) throws {
        let type : Type
        let bitWidth : BitWidth
        switch val {
        case let v as Int64 :
            type = .indirect_int
            bitWidth = BitWidth.width(int: v)
        case let v as UInt64 :
            type = .indirect_uint
            bitWidth = BitWidth.width(uint: v)
        case _ as Float :
            type = .indirect_float
            bitWidth = .width32
        case _ as Double :
            type = .indirect_float
            bitWidth = .width64
        default:
            throw FlexBufferEncodeError.unexpectedType
        }
        let byteWitdth = align(width: bitWidth)
        let iloc = buffer.count
        write(value: val, size: byteWitdth)
        stack.append(Value(value: UInt64(iloc), type: type, bitWidth: bitWidth))
    }
    
    private func align(width : BitWidth) -> UInt8 {
        let byteWidth = 1 << width.rawValue
        let paddingCount = paddingSize(bufSize: buffer.count, scalarSize: byteWidth)
        buffer += [UInt8](repeating: 0, count: paddingCount)
        return byteWidth
    }
    
    func write<T>(value : T, size : UInt8) {
        var v = value
        withUnsafeBytes(of: &v) {
            buffer += $0[0..<Int(size)]
        }
    }
    
    func writeOffset(value : UInt64, size : UInt8) {
        let reloff = UInt64(buffer.count) - value
        assert(size == 8 || reloff < UInt64(1 << UInt64(size * 8)))
        write(value: reloff, size: size)
    }
    
    func writeDouble(value : Double, size : UInt8){
        switch size {
        case 8:
            write(value: value, size: size)
        case 4:
            write(value: Float32(value), size: size)
        default:
            assertionFailure("Only 4 and 8 byte float numbers are supported")
        }
    }
    
    private func write(flxvalue : Value, width : UInt8) {
        switch flxvalue.type {
        case .null:
            write(value: 0, size: width)
        case .int:
            write(value: flxvalue.value.asInt, size: width)
        case .uint:
            write(value: flxvalue.value.asUInt, size: width)
        case .float:
            writeDouble(value: flxvalue.value.asDouble, size: width)
        default:
            writeOffset(value: flxvalue.value.asUInt, size: width)
        }
    }
    
    private func createBlob(data : [UInt8], length : Int, trailing : Int, type : Type) {
        let bitWidth = BitWidth.width(uint: UInt64(length))
        let byteWidth = align(width: bitWidth)
        write(value: length, size: byteWidth)
        let sloc = buffer.count
        self.buffer += data
        stack.append(Value(value: UInt64(sloc), type: type, bitWidth: bitWidth))
    }
    
    func startVector() -> Int {
        return stack.count
    }
    
    func startMap() -> Int {
        return stack.count
    }
    
    func endVector(start : Int, typed : Bool, fixed : Bool) -> Int {
        let vec = creteVector(start: start, vecLen: stack.count - start, step: 1, typed: typed, fixed: fixed)
        stack.removeLast(stack.count - start)
        stack.append(vec)
        return Int(vec.value.asUInt)
    }
    
    func endMap(start : Int) {
        var len = stack.count - start
        assert((len % 2) == 0, "We should have interleaved keys and values on the stack. Make sure it is an even number")
        len /= 2
        
        var sorted = true
        for i in stride(from: start, to: stack.count, by: 2) {
            assert(stack[i].type == .key, "Make sure keys are all strings")
            guard i + 2 < stack.count else {
                break
            }
            if shouldFilp(stack[i], stack[i+2]) {
                sorted = false
                break
            }
        }
        if sorted == false {
            for i in stride(from: start, to: stack.count, by: 2) {
                // Now sort values, so later we can do a binary seach lookup.
                // We want to sort 2 array elements at a time.
                // performing selection sort (https://en.wikipedia.org/wiki/Selection_sort)
                guard i + 2 < stack.count else {
                    break
                }
                var flipIndex = i
                for i2 in stride(from: i + 2, to: stack.count, by: 2) {
                    if shouldFilp(stack[flipIndex], stack[i2]) {
                        flipIndex = i2
                    }
                }
                if flipIndex != i {
                    let k = stack[flipIndex]
                    let v = stack[flipIndex + 1]
                    stack[flipIndex] = stack[i]
                    stack[flipIndex + 1] = stack[i + 1]
                    stack[i] = k
                    stack[i + 1] = v
                }
            }
        }
        
        let keys = creteVector(start: start, vecLen: len, step: 2, typed: true, fixed: false)
        let vec = creteVector(start: start + 1, vecLen: len, step: 2, typed: false, fixed: false, keys: keys)
        
        stack.removeLast(stack.count - start)
        stack.append(vec)
        
    }
    
    private func shouldFilp(_ v1 : Value, _ v2 : Value) -> Bool {
        var index = 0
        var c1 : UInt8
        var c2 : UInt8
        
        
        repeat {
            c1 = buffer[Int(v1.value.asInt + index)]
            c2 = buffer[Int(v2.value.asInt + index)]
            if c2 < c1 {
                return true
            } else if c1 < c2 {
                return false
            }
            index += 1
        } while c1 != 0 && c2 != 0
        return false
    }
    
    fileprivate func creteVector(start : Int, vecLen : Int, step : Int, typed : Bool,
                     fixed: Bool,
                     keys : Value? = nil) -> Value {
        // Figure out smallest bit width we can store this vector with.
        var bitWidth = BitWidth.width(uint: UInt64(vecLen))
        var prefixElems = 1
        
        if let keys = keys {
            // If this vector is part of a map, we will pre-fix an offset to the keys
            // to this vector.
            let elemWidth = keys.elementWidth(size: buffer.count, index: 0)
            bitWidth = BitWidth(rawValue: max(bitWidth.rawValue, elemWidth.rawValue))! // FIXME:
            prefixElems += 2
        }
        
        var vectorType = Type.key
        for i in stride(from: start, to: stack.count, by: step) {
            let elemWidth = stack[i].elementWidth(size: buffer.count, index: i + prefixElems)
            bitWidth = BitWidth(rawValue: max(bitWidth.rawValue, elemWidth.rawValue))! // FIXME:
            if typed {
                if i == start {
                    vectorType = stack[i].type
                } else {
                    assert(vectorType == stack[i].type, "you are writing a typed vector with elements that are not all the same type.")
                }
            }
        }
        assert(vectorType.isTypedVectorElement, "your fixed types are not one of: Int / UInt / Float / Key")
        let byteWidth = align(width: bitWidth)
        // Write vector. First the keys width/offset if available, and size.
        if let keys = keys {
            writeOffset(value: keys.value.asUInt, size: byteWidth)
            write(value: UInt64(1 << keys.minBitWidth.rawValue), size: byteWidth)
        }
        if !fixed {
            write(value: vecLen, size: byteWidth)
        }
        // Then the actual data.
        let vloc = buffer.count
        for i in stride(from: start, to: stack.count, by: step) {
            write(flxvalue: stack[i], width: byteWidth)
        }
        // Then the types.
        if !typed {
            for i in stride(from: start, to: stack.count, by: step) {
                buffer.append(stack[i].storedPackedType(width: bitWidth))
            }
        }
        
        return Value(value: UInt64(vloc),
                     type: keys != nil
                            ? .map
                            : (typed
                                ? vectorType.toTypedVector(length: UInt8(fixed ? vecLen : 0))
                                : .vector),
                     bitWidth: bitWidth)
    }
    
    public func finish() {
        assert(stack.count == 1, "you likely have objects that were never included in a parent. You need to have exactly one root to finish a buffer. Check your Start/End calls are matched, and all objects are inside some other object.")
        
        let byteWidth = align(width: stack[0].elementWidth(size: buffer.count, index: 0))
        write(flxvalue: stack[0], width: byteWidth)
        write(value: stack[0].storedPackedType(), size: 1)
        write(value: byteWidth, size: 1)
        
        finished = true
    }
}

public protocol FlxbValue {}
public protocol FlxbScalarValue : FlxbValue {}
public protocol FlxbBigScalarValue : FlxbScalarValue {}


extension Bool : FlxbScalarValue {}
extension UInt8 : FlxbScalarValue {}
extension Int8 : FlxbScalarValue {}
extension UInt16 : FlxbScalarValue {}
extension Int16 : FlxbScalarValue {}
extension UInt32 : FlxbScalarValue {}
extension Int32 : FlxbScalarValue {}
extension UInt64 : FlxbBigScalarValue {}
extension Int64 : FlxbBigScalarValue {}
extension UInt : FlxbScalarValue {}
extension Int : FlxbScalarValue {}
extension Float : FlxbBigScalarValue {}
extension Double : FlxbBigScalarValue {}
extension String : FlxbValue {}

public protocol FlexBufferVectorBuilder {
    func add(_ v : Any) throws
    func add<T : FlxbBigScalarValue>(indirectValue v : T) throws
    func vector(_ f : (FlexBufferVectorBuilder) throws -> ()) throws
    func map(_ f : (FlexBufferMapBuilder) throws -> ()) throws
}

extension FlexBuffer : FlexBufferVectorBuilder {
    public func add(_ v: Any) throws {
        handleValue(v)
    }
    
    public func add<T : FlxbBigScalarValue>(indirectValue v: T) throws {
        try self.pushIndirect(v)
    }
    
    public func map(_ f: (FlexBufferMapBuilder) throws -> ()) throws {
        let start = self.startMap()
        try f(self)
        _ = self.endMap(start: start)
    }
    
    public func vector(_ f: (FlexBufferVectorBuilder) throws -> ()) throws {
        let start = self.startVector()
        try f(self)
        _ = self.endVector(start: start, typed: false, fixed: false)
    }
}

public protocol FlexBufferMapBuilder {
    func add(key : String, value : Any) throws
    func add(key : StaticString, value : Any) throws
    func add<T : FlxbBigScalarValue>(key : String, indirectValue : T) throws
    func add<T : FlxbBigScalarValue>(key : StaticString, indirectValue : T) throws
    func vector(key : String, _ f : (FlexBufferVectorBuilder) throws -> ()) throws
    func vector(key : StaticString, _ f : (FlexBufferVectorBuilder) throws -> ()) throws
    func map(key : String, _ f : (FlexBufferMapBuilder) throws -> ()) throws
    func map(key : StaticString, _ f : (FlexBufferMapBuilder) throws -> ()) throws
}

extension FlexBuffer : FlexBufferMapBuilder {
    public func add<T : FlxbBigScalarValue>(key: String, indirectValue: T) throws {
        self.key(key)
        try pushIndirect(indirectValue)
    }
    public func add<T : FlxbBigScalarValue>(key: StaticString, indirectValue: T) throws {
        self.key(key)
        try pushIndirect(indirectValue)
    }
    public func add(key: String, value: Any) throws {
        self.key(key)
        handleValue(value)
    }
    public func add(key: StaticString, value: Any) throws {
        self.key(key)
        handleValue(value)
    }
    public func map(key: String, _ f: (FlexBufferMapBuilder) throws -> ()) throws {
        self.key(key)
        let start = self.startMap()
        try f(self)
        _ = self.endMap(start: start)
    }
    public func map(key: StaticString, _ f: (FlexBufferMapBuilder) throws -> ()) throws {
        self.key(key)
        let start = self.startMap()
        try f(self)
        _ = self.endMap(start: start)
    }
    public func vector(key: String, _ f: (FlexBufferVectorBuilder) throws -> ()) throws {
        self.key(key)
        let start = self.startVector()
        try f(self)
        _ = self.endVector(start: start, typed: false, fixed: false)
    }
    public func vector(key: StaticString, _ f: (FlexBufferVectorBuilder) throws -> ()) throws {
        self.key(key)
        let start = self.startVector()
        try f(self)
        _ = self.endVector(start: start, typed: false, fixed: false)
    }
}

public protocol FlexBufferEncoder {
    static func encode(_ v : Any) throws -> Data
    static func encode<T : FlxbScalarValue>(typedArray vs : [T]) throws -> Data
    static func encodeVector(_ f : (FlexBufferVectorBuilder) throws -> ()) throws -> Data
    static func encodeMap(_ f : (FlexBufferMapBuilder) throws -> ()) throws -> Data
}

extension FlexBuffer : FlexBufferEncoder {
    public static func encodeMap(_ f: (FlexBufferMapBuilder) throws -> ()) throws -> Data {
        let builder = FlexBuffer()
        try builder.map(f)
        builder.finish()
        return Data(bytes: builder.buffer)
    }

    public static func encodeVector(_ f: (FlexBufferVectorBuilder) throws -> ()) throws -> Data {
        let builder = FlexBuffer()
        try builder.vector(f)
        builder.finish()
        return Data(bytes: builder.buffer)
    }

    public static func encode<T : FlxbScalarValue>(typedArray vs : [T]) throws -> Data {
        let builder = FlexBuffer()
        builder.addArray(vs)
        builder.finish()
        return Data(bytes: builder.buffer)
    }

    public static func encode(_ v: Any) throws -> Data {
        let builder = FlexBuffer()
        builder.handleValue(v)
        builder.finish()
        return Data(bytes: builder.buffer)
    }
}

fileprivate func readInt(pointer : UnsafeRawPointer, width : UInt8) -> Int64? {
    if width == 1 {
        return Int64(pointer.load(as: Int8.self))
    }
    if width == 2 {
        return Int64(pointer.load(as: Int16.self))
    }
    if width == 4 {
        return Int64(pointer.load(as: Int32.self))
    }
    if width == 8 {
        return Int64(pointer.load(as: Int64.self))
    }
    return nil
}

fileprivate func readUInt(pointer : UnsafeRawPointer, width : UInt8) -> UInt64? {
    if width == 1 {
        return UInt64(pointer.load(as: UInt8.self))
    }
    if width == 2 {
        return UInt64(pointer.load(as: UInt16.self))
    }
    if width == 4 {
        return UInt64(pointer.load(as: UInt32.self))
    }
    if width == 8 {
        return UInt64(pointer.load(as: UInt64.self))
    }
    return nil
}

fileprivate func readFloat(pointer : UnsafeRawPointer, width : UInt8) -> Float? {
    if width == 4 {
        return pointer.load(as: Float.self)
    }
    if width == 8 {
        return Float(pointer.load(as: Double.self))
    }
    return nil
}

fileprivate func readDouble(pointer : UnsafeRawPointer, width : UInt8) -> Double? {
    if width == 4 {
        return Double(pointer.load(as: Float.self))
    }
    if width == 8 {
        return pointer.load(as: Double.self)
    }
    return nil
}

fileprivate func _indirect(pointer : UnsafeRawPointer, width : UInt8) -> UnsafeRawPointer? {
    guard let step = readUInt(pointer: pointer, width: width) else {
        return nil
    }
    return pointer - Int(step)
}


public struct FlxbReference {
    fileprivate let dataPointer : UnsafeRawPointer
    fileprivate let parentWidth : UInt8
    fileprivate let byteWidth : UInt8
    fileprivate let type : Type
    
    fileprivate init?(dataPointer : UnsafeRawPointer, parentWidth : UInt8, packedType : UInt8) {
        self.dataPointer = dataPointer
        self.parentWidth = parentWidth
        guard let byteWidth = BitWidth(rawValue: packedType & 3)?.rawValue,
            let type = Type(rawValue: packedType >> 2) else {
                return nil
        }
        self.byteWidth = 1 << byteWidth
        self.type = type
    }
    
    fileprivate init(dataPointer : UnsafeRawPointer, parentWidth : UInt8, byteWidth : UInt8, type : Type){
        self.dataPointer = dataPointer
        self.parentWidth = parentWidth
        self.byteWidth = byteWidth
        self.type = type
    }
    
    public var asInt : Int? {
        guard let r = asInt64 else {
            return nil
        }
        return Int(r)
    }
    
    public var asInt64 : Int64? {
        switch type {
        case .int :
            return readInt(pointer: dataPointer, width: parentWidth)
        case .indirect_int:
            if let p = self.indirect {
                return readInt(pointer: p, width: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asUInt : UInt? {
        guard let r = asUInt64 else {
            return nil
        }
        return UInt(r)
    }
    
    public var asUInt64 : UInt64? {
        switch type {
        case .uint :
            return readUInt(pointer: dataPointer, width: parentWidth)
        case .indirect_uint :
            if let p = self.indirect {
                return readUInt(pointer: p, width: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asFloat : Float? {
        switch type {
        case .float :
            return readFloat(pointer: dataPointer, width: parentWidth)
        case .indirect_float :
            if let p = self.indirect {
                return readFloat(pointer: p, width: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asDouble : Double? {
        switch type {
        case .float :
            return readDouble(pointer: dataPointer, width: parentWidth)
        case .indirect_float :
            if let p = self.indirect {
                return readDouble(pointer: p, width: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asBool : Bool? {
        switch type {
        case .int :
            let r = readInt(pointer: dataPointer, width: parentWidth)
            if r == 0 {
                return false
            }
            if r == 1 {
                return true
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asString : String? {
        switch type {
        case .string :
            if let p = self.indirect {
                return FlxbString(dataPointer: p, byteWidth: byteWidth).string
            }
            return nil
        case .key :
            if let p = self.indirect {
                return String(validatingUTF8: p.assumingMemoryBound(to: CChar.self))
            }
            return nil
            
        default:
            return nil
        }
    }
    
    fileprivate var asPointer : UnsafeRawPointer? {
        switch type {
        case .key :
            return self.indirect
        default:
            return nil
        }
    }
    
    public var asVector : FlxbVector? {
        if type.isTypedVector {
            if let p = self.indirect {
                return FlxbVector(dataPointer: p, byteWidth: byteWidth, type: type.typedVectorElementType)
            }
            return nil
        }
        switch type {
        case .vector :
            if let p = self.indirect {
                return FlxbVector(dataPointer: p, byteWidth: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    public var asMap : FlxbMap? {
        switch type {
        case .map :
            if let p = self.indirect {
                return FlxbMap(dataPointer: p, byteWidth: byteWidth)
            }
            return nil
        default:
            return nil
        }
    }
    
    private var indirect : UnsafeRawPointer? {
        return _indirect(pointer: dataPointer, width: parentWidth)
    }
}

public struct FlxbString {
    fileprivate let dataPointer : UnsafeRawPointer
    fileprivate let byteWidth : UInt8
    var count : Int {
        if let size = readUInt(pointer: dataPointer - Int(byteWidth), width: byteWidth) {
            return Int(size)
        }
        return 0
    }
    
    var string : String? {
        return String(validatingUTF8: dataPointer.assumingMemoryBound(to: CChar.self))
    }
}

public struct FlxbVector : Sequence {
    fileprivate let dataPointer : UnsafeRawPointer
    fileprivate let byteWidth : UInt8
    fileprivate let type : Type?
    
    fileprivate init(dataPointer : UnsafeRawPointer, byteWidth : UInt8, type : Type? = nil) {
        self.dataPointer = dataPointer
        self.byteWidth = byteWidth
        self.type = type
    }
    
    public var count : Int {
        if let size = readUInt(pointer: dataPointer - Int(byteWidth), width: byteWidth) {
            return Int(size)
        }
        return 0
    }
    
    public subscript(index: Int) -> FlxbReference? {
        let length = count
        guard index >= 0 && index < length else {
            return nil
        }
        if let type = type {
            return get(index, length, type)
        } else {
            return get(index, length)
        }
    }
    
    private func get(_ index : Int, _ length : Int) -> FlxbReference? {
        let packedType = (dataPointer + (length * Int(byteWidth))).load(fromByteOffset: index, as: UInt8.self)
        let elem = dataPointer + (index * Int(byteWidth))
        return FlxbReference(dataPointer: elem, parentWidth: byteWidth, packedType: packedType)
    }
    
    private func get(_ index : Int, _ length : Int, _ type : Type) -> FlxbReference? {
        let elem = dataPointer + (index * Int(byteWidth))
        return FlxbReference(dataPointer: elem, parentWidth: byteWidth, byteWidth: 1, type: type)
    }
    
    public func makeIterator() -> AnyIterator<FlxbReference> {
        
        var nextIndex = 0
        
        return AnyIterator<FlxbReference> {
            if(self.count <= nextIndex){
                return nil
            }
            let value = self[nextIndex]
            nextIndex += 1
            return value
        }
    }
}

public struct FlxbMap : Sequence {
    fileprivate let dataPointer : UnsafeRawPointer
    fileprivate let byteWidth : UInt8
    
    public var count : Int {
        if let size = readUInt(pointer: dataPointer - Int(byteWidth), width: byteWidth) {
            return Int(size)
        }
        return 0
    }
    
    public subscript(key: StaticString) -> FlxbReference? {
        guard let index = keyIndex(key: key) else {
            return nil
        }
        return values?[index]
    }
    
    public func get(key: String) -> FlxbReference? {
        guard let index = keyIndex(key: key) else {
            return nil
        }
        return values?[index]
    }
    
    private var keys : FlxbVector? {
        let keysOffset = dataPointer - Int(byteWidth) * 3
        if let p = _indirect(pointer: keysOffset, width: byteWidth),
            let bWidth = readUInt(pointer: keysOffset + Int(byteWidth), width: byteWidth) {
            return FlxbVector(dataPointer: p, byteWidth: UInt8(bWidth), type: .key)
        }
        return nil
    }
    
    private var values : FlxbVector? {
        return FlxbVector(dataPointer: dataPointer, byteWidth: byteWidth)
    }
    
    private func keyIndex(key : String) -> Int? {
        
        let key1 = key.utf8CString
        guard let _keys = keys else {
            return nil
        }
        
        func comp(i : Int) -> Int8? {
            guard let key2 = _keys[i]?.asPointer else {
                return nil
            }
            var index = 0
            
            while true {
                let c1 = key1[index]
                let c2 = key2.load(fromByteOffset: index, as: CChar.self)
                let c = c1 - c2
                if c != 0 {
                    return c
                }
                if c1 == 0 && c2 == 0 {
                    return 0
                }
                index += 1
            }
        }
        
        var low = 0
        var high = _keys.count - 1
        while low <= high {
            let mid = (high + low) >> 1
            guard let dif = comp(i: mid) else {
                return nil
            }
            if dif == 0 {
                return mid
            }
            if dif < 0 {
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        return nil
        
    }
    
    private func keyIndex(key : StaticString) -> Int? {
        
        let key1 = key.utf8Start
        guard let _keys = keys else {
            return nil
        }
        
        func comp(i : Int) -> Int8? {
            guard let key2 = _keys[i]?.asPointer else {
                return nil
            }
            var index = 0
            
            while true {
                let c1 = CChar(key1.advanced(by: index).pointee)
                let c2 = key2.load(fromByteOffset: index, as: CChar.self)
                let c = c1 &- c2
                if c != 0 {
                    return c
                }
                if c1 == 0 && c2 == 0 {
                    return 0
                }
                index += 1
            }
        }
        
        var low = 0
        var high = _keys.count - 1
        while low <= high {
            let mid = (high + low) >> 1
            guard let dif = comp(i: mid) else {
                return nil
            }
            if dif == 0 {
                return mid
            }
            if dif < 0 {
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        return nil
        
    }
    
    public func makeIterator() -> AnyIterator<(key : String, value: FlxbReference)> {
        
        var nextIndex = 0
        let _keys = keys
        let _values = values
        
        return AnyIterator<(key : String, value: FlxbReference)> {
            if(self.count <= nextIndex){
                return nil
            }
            if let key = _keys?[nextIndex]?.asString,
                let value = _values?[nextIndex] {
                let value = (key: key, value: value)
                nextIndex += 1
                return value
            }
            return nil
        }
    }
}

public protocol FlexBufferDecoder {
    static func decode(data : Data) -> FlxbReference?
}

extension FlexBuffer : FlexBufferDecoder {
    public static func decode(data: Data) -> FlxbReference? {
        guard data.count > 2 else {
            return nil
        }
        let byteWidth = data[data.count - 1]
        let packedType = data[data.count - 2]
        
//        let p1 : UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: data.count)
//        let originalBuffer = UnsafeMutableBufferPointer(start: p1, count: data.count)
//        _ = data.copyBytes(to: originalBuffer)
//        let pointer = UnsafeRawPointer(p1)
        var pointer : UnsafePointer<UInt8>! = nil
        data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            pointer = u8Ptr
        }
        let p = pointer.advanced(by: (data.count - Int(byteWidth) - 2))
        return FlxbReference(dataPointer: UnsafeRawPointer(p), parentWidth: byteWidth, packedType: packedType)
    }
}
