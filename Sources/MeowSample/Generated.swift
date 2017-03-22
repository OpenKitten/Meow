// Generated using Sourcery 0.5.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow



  func meowReinstantiateObjectIdArray(from source: Primitive?) throws -> [ObjectId]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> ObjectId in
          return try Meow.Helpers.requireValue(ObjectId(rawValue), keyForError: "index \(index) on array of ObjectId")
      }
  }


  func meowReinstantiateStringArray(from source: Primitive?) throws -> [String]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> String in
          return try Meow.Helpers.requireValue(String(rawValue), keyForError: "index \(index) on array of String")
      }
  }


  func meowReinstantiateIntArray(from source: Primitive?) throws -> [Int]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int in
          return try Meow.Helpers.requireValue(Int(rawValue), keyForError: "index \(index) on array of Int")
      }
  }


  func meowReinstantiateInt32Array(from source: Primitive?) throws -> [Int32]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int32 in
          return try Meow.Helpers.requireValue(Int32(rawValue), keyForError: "index \(index) on array of Int32")
      }
  }


  func meowReinstantiateBoolArray(from source: Primitive?) throws -> [Bool]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Bool in
          return try Meow.Helpers.requireValue(Bool(rawValue), keyForError: "index \(index) on array of Bool")
      }
  }


  func meowReinstantiateDocumentArray(from source: Primitive?) throws -> [Document]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Document in
          return try Meow.Helpers.requireValue(Document(rawValue), keyForError: "index \(index) on array of Document")
      }
  }


  func meowReinstantiateDoubleArray(from source: Primitive?) throws -> [Double]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Double in
          return try Meow.Helpers.requireValue(Double(rawValue), keyForError: "index \(index) on array of Double")
      }
  }


  func meowReinstantiateDataArray(from source: Primitive?) throws -> [Data]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Data in
          return try Meow.Helpers.requireValue(Data(rawValue), keyForError: "index \(index) on array of Data")
      }
  }


  func meowReinstantiateBinaryArray(from source: Primitive?) throws -> [Binary]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Binary in
          return try Meow.Helpers.requireValue(Binary(rawValue), keyForError: "index \(index) on array of Binary")
      }
  }


  func meowReinstantiateDateArray(from source: Primitive?) throws -> [Date]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Date in
          return try Meow.Helpers.requireValue(Date(rawValue), keyForError: "index \(index) on array of Date")
      }
  }


  func meowReinstantiateRegularExpressionArray(from source: Primitive?) throws -> [RegularExpression]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> RegularExpression in
          return try Meow.Helpers.requireValue(RegularExpression(rawValue), keyForError: "index \(index) on array of RegularExpression")
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
          document["email"] = self.email 
          document["name"] = self.name 
          document["genders"] = self.genders.map { $0.meowSerialize() } 
          document["favoriteNumbers"] = self.favoriteNumbers 
          document["address"] = self.address?.meowSerialize() 
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
           /// email: String
            var email: VirtualString { return VirtualString(name: keyPrefix + "email") } 
           /// name: String
            var name: VirtualString { return VirtualString(name: keyPrefix + "name") } 
           /// genders: [Gender]
           
           /// favoriteNumbers: [Int]
           
           /// address: Address?
           

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      } // end VirtualInstance

      enum Key : String {        
          case _id        
          case email        
          case name        
          case genders        
          case favoriteNumbers        
          case address        


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
          switch rawValue {
             case "male": self = .male
             case "female": self = .female
             case "undecided": self = .undecided
            
            default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
          }
        
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
        return self.meowSerialize()
      }

      func meowSerialize() -> Primitive {
        
          switch self {
             case .male: return "male"
             case .female: return "female"
             case .undecided: return "undecided"
            
          }
        
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
    extension Address : ConcreteSerializable {
    
    init(meowDocument source: Document) throws {      
        self.streetName = try Meow.Helpers.requireValue(String(source["streetName"]), keyForError: "streetName")  /* String */ 
    }
    


       init?(meowValue: Primitive?) throws {
        guard let document = Document(meowValue) else {
          return nil
        }
        try self.init(meowDocument: document)
      }

      func meowSerialize() -> Document {
        var document = Document()
        
          document["streetName"] = self.streetName 
        return document
      }

      func meowSerialize(resolvingReferences: Bool) throws -> Document {
        // TODO: re-evaluate references
          return self.meowSerialize()
      }

      struct VirtualInstance {
        var keyPrefix: String

        
           /// streetName: String
            var streetName: VirtualString { return VirtualString(name: keyPrefix + "streetName") } 

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      } // end VirtualInstance

      enum Key : String {        
          case streetName        


      }

    } // end struct or class extension of Address

  func meowReinstantiateAddressArray(from source: Primitive?) throws -> [Address]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Address in
          return try Meow.Helpers.requireValue(Address(meowValue: rawValue), keyForError: "index \(index) on array of Address")
      }
  }

// Serializables parsed: User,Gender,Address
