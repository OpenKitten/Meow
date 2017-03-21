// Generated using Sourcery 0.5.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow



  extension Array where Element == ObjectId {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(ObjectId(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == String {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(String(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Int {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Int(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Int32 {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Int32(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Bool {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Bool(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Document {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Document(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Double {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Double(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Data {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Data(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Binary {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Binary(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == Date {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(Date(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }


  extension Array where Element == RegularExpression {
    init?(_ primitive: Primitive?) {
      guard let doc = Document(primitive) else {
        return nil
      }

      let schrodingerSelf = try? doc.arrayValue.map { primitive in
        return try Meow.Helpers.requireValue(RegularExpression(primitive), keyForError: "")
      }

      guard let me = schrodingerSelf else {
        return nil
      }

      self = me
    }
  }

    // Struct or Class extension
    extension User : ConcreteSerializable {
    // sourcery:inline:User.Meow
    // sourcery:end

      convenience init?(meowValue: Primitive?) throws {
        guard let document = Document(meowValue) else {
          return nil
        }
        try self.init(meowDocument: document)
      }

      func meowSerialize() -> Document {
        var document = Document()
        
          document["_id"] = self._id 
          document["username"] = self.username 
          document["password"] = self.password 
          document["age"] = self.age 
          document["gender"] = self.gender?.meowSerialize() 
          document["details"] = self.details?.meowSerialize() 
          document["preferences"] = self.preferences.map { $0.meowSerialize() }  // parsed element string: Preference 
          document["extraPreferences"] = self.extraPreferences?.map { $0.meowSerialize() }  // parsed element string: Preference 
        return document
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Document {
        // TODO: re-evaluate references
          return self.meowSerialize()
      }

      struct VirtualInstance {
        var keyPrefix: String

        
           /// _id: ObjectId
            var _id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "_id") } 
           /// username: String
            var username: VirtualString { return VirtualString(name: keyPrefix + "username") } 
           /// password: String
            var password: VirtualString { return VirtualString(name: keyPrefix + "password") } 
           /// age: Int?
            var age: VirtualNumber { return VirtualNumber(name: keyPrefix + "age") } 
           /// gender: Gender?
            var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: keyPrefix + "gender") } 
           /// details: Details?
           
           /// preferences: [Preference]
           
           /// extraPreferences: [Preference]?
           

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      }
    } // end struct or class extension of User

      extension User : ConcreteModel {
        static let meowCollection: MongoKitten.Collection = Meow.database["user"]
        var meowReferencesWithValue: ReferenceValues { return [] }

        static func find(_ closure: ((VirtualInstance) -> (Query))) throws -> CollectionSlice<User> {
          let query = closure(VirtualInstance())
          return try self.find(query)
        }

        static func findOne(_ closure: ((VirtualInstance) -> (Query))) throws -> User? {
          let query = closure(VirtualInstance())
          return try self.findOne(query)
        }

        static func count(_ closure: ((VirtualInstance) -> (Query))) throws -> Int {
          let query = closure(VirtualInstance())
          return try self.count(query)
        }

        static func createIndex(named name: String? = nil, withParameters closure: ((VirtualInstance, IndexSubject) -> ())) throws {
          let indexSubject = IndexSubject()
          closure(VirtualInstance(), indexSubject)

          try meowCollection.createIndexes([(name: name ?? "", parameters: indexSubject.makeIndexParameters())])
        }
      }
    
  func meowReinstantiateUserArray(from source: Primitive?) throws -> [User]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> User in
          return try Meow.Helpers.requireValue(User(meowValue: rawValue), keyForError: "index \(index) on array of User")
      }
  }


    // Enum extension
    extension Gender : ConcreteSingleValueSerializable {
      /// Creates a `Gender` from a BSON Primtive
      init(meowValue: Primitive?) throws {
        let rawValue = try Meow.Helpers.requireValue(String(meowValue), keyForError: "enum Gender")
        self = try Meow.Helpers.requireValue(Gender(rawValue: rawValue), keyForError: "enum Gender")
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
        return self.meowSerialize()
      }

      func meowSerialize() -> Primitive {
        return self.rawValue
      }

      struct VirtualInstance {
        /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
        static func ==(lhs: VirtualInstance, rhs: Gender?) -> Query {
          return lhs.keyPrefix == rhs?.meowSerialize()
        }

        var keyPrefix: String

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      }
    }
  
  func meowReinstantiateGenderArray(from source: Primitive?) throws -> [Gender]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Gender in
          return try Meow.Helpers.requireValue(Gender(meowValue: rawValue), keyForError: "index \(index) on array of Gender")
      }
  }

    // Struct or Class extension
    extension Details : ConcreteSerializable {
    // sourcery:inline:Details.Meow
    // sourcery:end

       init?(meowValue: Primitive?) throws {
        guard let document = Document(meowValue) else {
          return nil
        }
        try self.init(meowDocument: document)
      }

      func meowSerialize() -> Document {
        var document = Document()
        
          document["firstName"] = self.firstName 
          document["lastName"] = self.lastName 
        return document
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Document {
        // TODO: re-evaluate references
          return self.meowSerialize()
      }

      struct VirtualInstance {
        var keyPrefix: String

        
           /// firstName: String?
            var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") } 
           /// lastName: String?
            var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") } 

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      }
    } // end struct or class extension of Details

  func meowReinstantiateDetailsArray(from source: Primitive?) throws -> [Details]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Details in
          return try Meow.Helpers.requireValue(Details(meowValue: rawValue), keyForError: "index \(index) on array of Details")
      }
  }


    // Enum extension
    extension Preference : ConcreteSingleValueSerializable {
      /// Creates a `Preference` from a BSON Primtive
      init(meowValue: Primitive?) throws {
        let rawValue = try Meow.Helpers.requireValue(String(meowValue), keyForError: "enum Preference")
        self = try Meow.Helpers.requireValue(Preference(rawValue: rawValue), keyForError: "enum Preference")
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
        return self.meowSerialize()
      }

      func meowSerialize() -> Primitive {
        return self.rawValue
      }

      struct VirtualInstance {
        /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
        static func ==(lhs: VirtualInstance, rhs: Preference?) -> Query {
          return lhs.keyPrefix == rhs?.meowSerialize()
        }

        var keyPrefix: String

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      }
    }
  
  func meowReinstantiatePreferenceArray(from source: Primitive?) throws -> [Preference]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Preference in
          return try Meow.Helpers.requireValue(Preference(meowValue: rawValue), keyForError: "index \(index) on array of Preference")
      }
  }

// Serializables parsed: User,Gender,Details,Preference
