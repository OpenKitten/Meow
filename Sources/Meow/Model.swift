import Foundation
import MongoKitten

/// Private base protocol for `Model` without Self or associated type requirements
public protocol _Model: class, Codable {
    // MARK: - Serialization
    
    /// The collection name instances of the model live in. A default implementation is provided.
    static var collectionName: String { get }
    
    /// The BSON decoder used for decoding instances of this model. A default implementation is provided.
    static var decoder: BSONDecoder { get }
    
    /// The BSON encoder used for encoding instances of this model. A default implementation is provided.
    static var encoder: BSONEncoder { get }
}

public typealias MeowIdentifier = Primitive & Hashable

public protocol Model: _Model {
    associatedtype Identifier: MeowIdentifier
    
    /// The `_id` of the model. *This property MUST be encoded with `_id` as key*
    var _id: Identifier { get set }
}

// MARK: - Default implementations
public extension Model {
    static var collectionName: String {
        return String(describing: Self.self) // Will be the name of the type
    }
    
    static var decoder: BSONDecoder {
        return BSONDecoder()
    }
    
    static var encoder: BSONEncoder {
        return BSONEncoder()
    }
}

public extension Model where Self: Hashable {
    
    /// Provides a default implementation of Hashable for Models, that uses only the _id for Hashable conformance
    public var hashValue: Int {
        return _id.hashValue
    }
    
    /// Compares the given models using the _id
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs._id == rhs._id
    }
    
}
