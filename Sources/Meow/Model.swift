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
    
    // MARK: - Hooks
    
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    func willSave(with context: Meow.Context) throws
    
    /// Will be called when the Model has been saved.
    func didSave(with context: Meow.Context) throws
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    func willDelete(with context: Meow.Context) throws
    
    /// Will be called when the Model is deleted.
    // At this point, it is no longer in the database and saves will no longer
    // work because the ObjectId is invalidated.
    func didDelete(with context: Meow.Context) throws
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
    
    func willSave(with context: Meow.Context) throws {}
    func didSave(with context: Meow.Context) throws {}
    func willDelete(with context: Meow.Context) throws {}
    func didDelete(with context: Meow.Context) throws {}
}
