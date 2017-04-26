// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import MongoKitten
import BSON
import Foundation


extension ObjectId : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(ObjectId(source), keyForError: "primitive ObjectId")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension String : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(String(source), keyForError: "primitive String")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Int : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Int(source), keyForError: "primitive Int")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Int32 : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Int32(source), keyForError: "primitive Int32")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Bool : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Bool(source), keyForError: "primitive Bool")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Document : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Document(source), keyForError: "primitive Document")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Double : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Double(source), keyForError: "primitive Double")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Data : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Data(source), keyForError: "primitive Data")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Binary : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Binary(source), keyForError: "primitive Binary")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Date : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Date(source), keyForError: "primitive Date")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension RegularExpression : Serializable {
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(RegularExpression(source), keyForError: "primitive RegularExpression")
	}
	
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	