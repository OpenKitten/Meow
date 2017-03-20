// Generated using Sourcery 0.5.8 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import MeowMongo





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
  




  extension Gender : ConcreteSingleValueSerializable {
    
    init(value: Primitive?) throws {
      let value = try Meow.Helpers.requireValue(value, keyForError: "")
      let primitiveValue: String = try Meow.Helpers.requireValue(String(value), keyForError: "")
      let me: Gender = try Meow.Helpers.requireValue(Gender(rawValue: primitiveValue), keyForError: "")

      self = me
    }

    
    func meowSerialize() -> Primitive {
      return self.rawValue
    }

    
    func meowSerialize(resolvingReferences: Bool = false) throws -> Primitive {
      return self.rawValue
    }

    
    struct VirtualInstance {
      
      static func ==(lhs: VirtualInstance, rhs: Gender) -> Query {
        return lhs.keyPrefix == rhs.meowSerialize()
      }

      var keyPrefix: String

      init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
      }
    }
  }

  extension Preference : ConcreteSingleValueSerializable {
    
    init(value: Primitive?) throws {
      let value = try Meow.Helpers.requireValue(value, keyForError: "")
      let primitiveValue: String = try Meow.Helpers.requireValue(String(value), keyForError: "")
      let me: Preference = try Meow.Helpers.requireValue(Preference(rawValue: primitiveValue), keyForError: "")

      self = me
    }

    
    func meowSerialize() -> Primitive {
      return self.rawValue
    }

    
    func meowSerialize(resolvingReferences: Bool = false) throws -> Primitive {
      return self.rawValue
    }

    
    struct VirtualInstance {
      
      static func ==(lhs: VirtualInstance, rhs: Preference) -> Query {
        return lhs.keyPrefix == rhs.meowSerialize()
      }

      var keyPrefix: String

      init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
      }
    }
  }



  extension User : ConcreteSerializable {
    func meowSerialize() -> Document {
      return (try? self.meowSerialize(resolvingReferences: false) ) ?? Document()
    }

    func meowSerialize(resolvingReferences: Bool) throws -> Document {
      
        var doc: Document = ["_id": self.id]
      

      

      
          doc["username"] = self.username
          
          doc["password"] = self.password
          
          doc["age"] = self.age
          
          doc["gender"] = self.gender?.meowSerialize()
          
          doc["details"] = self.details?.meowSerialize()
          
          doc["preferences"] = self.preferences.map { $0.meowSerialize() }
          // If it's an array of references
        
          doc["extraPreferences"] = self.extraPreferences?.map { $0.meowSerialize() }
          // If it's an array of references
        

      return doc
    }

    
   convenience  init(fromDocument source: Document) throws {
      var source = source
      // Extract all properties
      
      
        
        
          let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
        
        
          
            // The property is a BSON type, so we can just extract it from the document:
            
              let usernameValue: String = try Meow.Helpers.requireValue(String(source.removeValue(forKey: "username")), keyForError: "username")
            
          
        
      
        
        
          
            // The property is a BSON type, so we can just extract it from the document:
            
              let passwordValue: String = try Meow.Helpers.requireValue(String(source.removeValue(forKey: "password")), keyForError: "password")
            
          
        
      
        
        
          
            // The property is a BSON type, so we can just extract it from the document:
            
              let ageValue: Int? = Int(source.removeValue(forKey: "age"))
            
          
        
      
        
        
          
            
              let genderValue: Gender?
              
                if let sourceVal = source.removeValue(forKey: "gender") {
                  genderValue = try Gender(value: sourceVal)
                } else {
                  genderValue = nil
                }
              
            
          
        
      
        
        
          
            
              let detailsValue: Details?
              

                if let detailsDocument: Document = source.removeValue(forKey: "details") as? Document {
                  detailsValue = try Details(fromDocument: detailsDocument)
                } else {
                  detailsValue = nil
                }
              
            
          
        
      
        
        
          

          
            let preferencesPrimitiveValues = try Meow.Helpers.requireValue(Document(source.removeValue(forKey: "preferences")), keyForError: "preferences").arrayValue
            let preferencesValue: [Preference] = try preferencesPrimitiveValues.map {
              try Preference(value: $0)
            }
          
        
      
        
        
          

          
            let extraPreferencesPrimitiveValues = try Document(source.removeValue(forKey: "extraPreferences"))?.arrayValue
            let extraPreferencesValue: [Preference]? = try extraPreferencesPrimitiveValues?.map {
              try Preference(value: $0)
            }
          
        
      

      // Uses the first existing initializer
      // TODO: Support multiple/more complex initializers
      try self.init(
        
        
          username: usernameValue
          
            ,
          
        
          password: passwordValue
          
            ,
          
        
          age: ageValue
          
            ,
          
        
          gender: genderValue
          
        
      )

      // Sets the other variables
      
      
        
        
          self.id = idValue
        
      
        
        
          self.username = usernameValue
        
      
        
        
          self.password = passwordValue
        
      
        
        
          self.age = ageValue
        
      
        
        
          self.gender = genderValue
        
      
        
        
          self.details = detailsValue
        
      
        
        
          self.preferences = preferencesValue
        
      
        
        
          self.extraPreferences = extraPreferencesValue
        
      
    }

    
    struct VirtualInstance {
      var keyPrefix: String

      
      
        
        // id: ObjectId
        
          var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
        
      
        
        // username: String
        
          var username: VirtualString { return VirtualString(name: keyPrefix + "username") }
        
      
        
        // password: String
        
          var password: VirtualString { return VirtualString(name: keyPrefix + "password") }
        
      
        
        // age: Int?
        
          var age: VirtualNumber { return VirtualNumber(name: keyPrefix + "age") }
        
      
        
        // gender: Gender?
        
          
            var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: "gender") }
          
        
      
        
        // details: Details?
        
          
            var details: Details.VirtualInstance { return Details.VirtualInstance(keyPrefix: "details.") }
          
        
      
        
        // preferences: [Preference]
        
          
            var preferences: VirtualSingleValueArray<Preference> { return VirtualSingleValueArray<Preference>(name: keyPrefix + "preferences") }
          
        
      
        
        // extraPreferences: [Preference]?
        
          
            var extraPreferences: VirtualSingleValueArray<Preference> { return VirtualSingleValueArray<Preference>(name: keyPrefix + "extraPreferences") }
          
        
      

      init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
      }
    }

    
    var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      

      return result
    }
  }

  extension Details : ConcreteSerializable {
    func meowSerialize() -> Document {
      return (try? self.meowSerialize(resolvingReferences: false) ) ?? Document()
    }

    func meowSerialize(resolvingReferences: Bool) throws -> Document {
      
        var doc = Document()
      

      

      
          doc["firstName"] = self.firstName
          
          doc["lastName"] = self.lastName
          

      return doc
    }

    
   init(fromDocument source: Document) throws {
      var source = source
      // Extract all properties
      
      
        
        
          
            // The property is a BSON type, so we can just extract it from the document:
            
              let firstNameValue: String? = String(source.removeValue(forKey: "firstName"))
            
          
        
      
        
        
          
            // The property is a BSON type, so we can just extract it from the document:
            
              let lastNameValue: String? = String(source.removeValue(forKey: "lastName"))
            
          
        
      

      // Uses the first existing initializer
      // TODO: Support multiple/more complex initializers
      try self.init(
        
        
      )

      // Sets the other variables
      
      
        
        
          self.firstName = firstNameValue
        
      
        
        
          self.lastName = lastNameValue
        
      
    }

    
    struct VirtualInstance {
      var keyPrefix: String

      
      
        
        // firstName: String?
        
          var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") }
        
      
        
        // lastName: String?
        
          var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") }
        
      

      init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
      }
    }

    
    var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      

      return result
    }
  }




  extension User : ConcreteModel {
    static let meowCollection = Meow.database["user"]

    static func find(_ closure: ((VirtualInstance) -> (Query))) throws -> Cursor<User> {
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


