//
//  KeyPathListable.swift
//  Meow
//
//  Created by Robbert Brandsma on 26-06-17.
//

import Foundation

public protocol KeyPathListable {
    static var allKeyPaths: [String : AnyKeyPath] { get }
}

extension PartialKeyPath where Root : KeyPathListable {
    public func makeIdentifier() throws -> String {
        guard let path = (Root.allKeyPaths.first { $0.value == self }) else {
            throw QueryBuilderError.unknownKeyPath
        }
        
        return path.key
    }
}

protocol MeowWritableKeyPath {
    func write<T>(to: inout T, newValue: Any) throws
}

protocol MeowNilWritableKeyPath {
    func writeNil(to: inout Any) throws
}

enum KeyPathUpdateError : Error {
    case invalidRootOrValue
    case unknownKeyPath
    case keyPathNotWritable
    case incompatibleTypes(expected: Any.Type, got: Any.Type)
    case pathIsNotOptional
    case unconvertibleValue
}

extension WritableKeyPath : MeowWritableKeyPath {
    func write<T>(to: inout T, newValue: Any) throws {
        guard var root = to as? Root, let newValue = newValue as? Value else {
            throw KeyPathUpdateError.invalidRootOrValue
        }
        
        root[keyPath: self] = newValue
        
        to = root as! T
    }
}

fileprivate protocol _HackyOptional {}
extension Optional : _HackyOptional {}

extension WritableKeyPath : MeowNilWritableKeyPath {
    func writeNil(to: inout Any) throws {
        throw KeyPathUpdateError.pathIsNotOptional
    }
}

extension WritableKeyPath where Value : _HackyOptional {
    func writeNil(to: inout Any) throws {
        fatalError("This works!")
    }
}

protocol TypeUnwrappable {
    static var unwrappedType: Any.Type { get }
}

extension Optional : TypeUnwrappable {
    static var unwrappedType: Any.Type { return Wrapped.self }
}

fileprivate struct DecodingHelper<T : Decodable> : Decodable {
    var value: T
}

extension Decodable {
    fileprivate static func from(document: Document, with decoder: BSONDecoder) throws -> Self {
        return try decoder.decode(Self.self, from: document)
    }
    
    fileprivate static func from(primitive: Primitive?, with decoder: BSONDecoder) throws -> Self {
        let helperDocument: Document = ["value": primitive]
        let helper = try decoder.decode(DecodingHelper<Self>.self, from: helperDocument)
        return helper.value
    }
}

typealias SettableKeyPath = AnyKeyPath & MeowWritableKeyPath

private func makeValue(from primitive: Primitive?, for keyPath: SettableKeyPath) throws -> Any {
    var expectedType = type(of: keyPath).valueType
    var givenType: Any.Type = type(of: primitive)
    
    // Unwrap the input type
    if let primitive = primitive {
        givenType = type(of: primitive)
    }
    
    // Unwrap the output type
    if let unwrappableExpected = expectedType as? TypeUnwrappable.Type {
        expectedType = unwrappableExpected.unwrappedType
    }
    
    // Set nil if possible
    if primitive is NSNull {
        guard type(of: keyPath).valueType is _HackyOptional.Type else {
            throw KeyPathUpdateError.incompatibleTypes(expected: expectedType, got: givenType)
        }
        
        let hackyNil: Any? = nil
        return hackyNil as Any
    }
    
    // If the given type is already of the expected type
    if let primitive = primitive, givenType == expectedType {
        return primitive
    }
    
    // If the expected type is decodable and the value is a document, unwrap from the document
    if let document = primitive as? Document, let expectedType = expectedType as? Decodable.Type {
        return try expectedType.from(document: document, with: BSONDecoder())
    }
    
    // For single value things like enums
    if let expectedType = expectedType as? Decodable.Type {
        return try expectedType.from(primitive: primitive, with: BSONDecoder())
    }
    
    // Numeric types
    if let primitive = primitive, let expectedType = expectedType as? BSONNumericInitializable.Type, let value = expectedType.init(bsonNumber: primitive) {
        return value
    }
    
    throw KeyPathUpdateError.incompatibleTypes(expected: expectedType, got: givenType)
}

extension KeyPathListable {
    public mutating func update(with document: Document) throws {
        // Gather keypaths and values first, so any errors are thrown on time
        let keyPathsAndValues: [(SettableKeyPath, Any)] = try document.map { (key, primitive) in
            guard let keyPath = Self.allKeyPaths[key] else {
                throw KeyPathUpdateError.unknownKeyPath
            }
            
            guard let settableKeyPath = keyPath as? SettableKeyPath else {
                throw KeyPathUpdateError.keyPathNotWritable
            }
            
            let value = try makeValue(from: primitive, for: settableKeyPath)
            
            return (settableKeyPath, value)
        }
        
        // Now do the setting; this usually shouldn't error
        for (path, value) in keyPathsAndValues {
            try path.write(to: &self, newValue: value)
        }
    }
}

fileprivate protocol BSONNumericInitializable {
    init?(bsonNumber number: Primitive)
}

extension BinaryInteger where Self : BSONNumericInitializable {
    init?(bsonNumber number: Primitive) {
        switch number {
        case let number as Int:
            self.init(exactly: number)
        case let number as Int32:
            self.init(exactly: number)
        case let number as Double:
            self.init(exactly: number)
        default:
            return nil
        }
    }
}

extension Int : BSONNumericInitializable {}
extension Int8 : BSONNumericInitializable {}
extension Int16 : BSONNumericInitializable {}
extension Int32 : BSONNumericInitializable {}
extension Int64 : BSONNumericInitializable {}
extension UInt : BSONNumericInitializable {}
extension UInt16 : BSONNumericInitializable {}
extension UInt32 : BSONNumericInitializable {}
extension UInt64 : BSONNumericInitializable {}

protocol DoubleInitializable {
    init(_ other: Double)
}

extension FloatingPoint where Self : BSONNumericInitializable & DoubleInitializable {
    init?(bsonNumber number: Primitive) {
        switch number {
        case let number as Int:
            self.init(number)
        case let number as Int32:
            self.init(number)
        case let number as Double:
            self.init(number)
        default:
            return nil
        }
    }
}

extension Double : BSONNumericInitializable, DoubleInitializable {}
extension Float : BSONNumericInitializable, DoubleInitializable {}

