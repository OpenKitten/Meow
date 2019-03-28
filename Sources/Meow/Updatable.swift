import Foundation
import NIO

enum KeyPathUpdateError: Error {
    case invalidRootOrValue
}

public struct DecoderExtractor: Decodable {
    public let decoder: Decoder
    
    public init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

public struct UpdateCodingKey: CodingKey {
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init(_ value: String) {
        self.stringValue = value
    }
    
    public var intValue: Int?
    
    public init?(intValue: Int) {
        return nil
    }
}

public protocol MeowWritableKeyPath {
    func write<T: KeyPathQueryable>(to: inout T, from container: KeyedDecodingContainer<UpdateCodingKey>) throws -> Bool
}

extension WritableKeyPath: MeowWritableKeyPath where Root: KeyPathQueryable, Value: Decodable {
    /// - returns: `true` if the value was changed
    public func write<T: KeyPathQueryable>(to: inout T, from container: KeyedDecodingContainer<UpdateCodingKey>) throws -> Bool {
        var didUpdate = false
        
        guard var root = to as? Root else {
            throw KeyPathUpdateError.invalidRootOrValue
        }
        
        let keyString = try Root.makeQueryPath(for: self)
        let key = UpdateCodingKey(keyString)
        if let newValue = try container.decodeIfPresent(Value.self, forKey: key) {
            root[keyPath: self] = newValue
            didUpdate = true
        } else if let optionalKeyPath = self as? OptionalKeyPath, let isNull = try? container.decodeNil(forKey: key), isNull {
            try optionalKeyPath.writeNil(to: &root)
        }
        // TODO: decode null
        
        // root is converted from T above so this does not fail
        // swiftlint:disable force_cast
        to = root as! T
        
        return didUpdate
    }
}

fileprivate protocol OptionalKeyPath {
    func writeNil<T>(to: inout T) throws
}

extension WritableKeyPath: OptionalKeyPath where Value: ExpressibleByNilLiteral {
    func writeNil<T>(to: inout T) throws {
        guard var root = to as? Root else {
            throw KeyPathUpdateError.invalidRootOrValue
        }
        
        root[keyPath: self] = nil
        
        to = root as! T
    }
}

public extension Decoder {
    /// - returns: An array containing the key paths that were updated
    public func update<T: KeyPathQueryable>(_ instance: T, withAllowedKeyPaths keyPaths: [MeowWritableKeyPath]) throws -> [PartialKeyPath<T>] {
        let container = try self.container(keyedBy: UpdateCodingKey.self)
        
        // must pass as inout to the KeyPath, hence the var
        // models are always classes
        var instance = instance
        
        var updatedKeyPaths = [PartialKeyPath<T>]()
        
        for keyPath in keyPaths {
            let didUpdate = try keyPath.write(to: &instance, from: container)
            if didUpdate {
                // this should never fail, it would make no sense
                // swiftlint:disable force_cast
                updatedKeyPaths.append(keyPath as! PartialKeyPath<T>)
            }
        }
        
        return updatedKeyPaths
    }
}

public extension JSONDecoder {
    func decoder(from data: Data) throws -> Decoder {
        return try self.decode(DecoderExtractor.self, from: data).decoder
    }
    
    /// - returns: An array containing the key paths that were updated
    public func update<T: QueryableModel>(_ instance: T, from data: Data, withAllowedKeyPaths keyPaths: [MeowWritableKeyPath]) throws -> [PartialKeyPath<T>] {
        // It seems not ideal that MeowWritableKeyPath currently is not restricted to Root == T
        assert(keyPaths.allSatisfy { $0 as? PartialKeyPath<T> != nil }, "Calling update for a certain model with allowed key paths of a different type does not make sense")
        
        let decoder = try self.decoder(from: data)
        return try decoder.update(instance, withAllowedKeyPaths: keyPaths)
    }
}
