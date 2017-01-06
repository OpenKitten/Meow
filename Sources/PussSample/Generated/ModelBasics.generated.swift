// Generated using Sourcery 0.5.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Puss
import Foundation



extension Dog : ConcreteSerializable {
  func pussSerialize() -> Document {
      
      var doc: Document = ["_id": self.id]
      

      
      // id: ObjectId (ObjectId)
      
      
      
      
      // name: String (String)
      
        doc["name"] = self.name
      
      
      
      
      // preferences: Preferences? (Preferences)
      
      
      
        doc["preferences"] = self.preferences?.pussSerialize()
      
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
      // Extract all properties
      
      // loop: id

      
      
      
      

      
      let idValue: ObjectId = try Puss.Helpers.requireValue(source["_id"], keyForError: "id")
      
      
      // loop: name

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let nameValue: String = try Puss.Helpers.requireValue(source["name"], keyForError: "name")
      
      

      
      
      // loop: preferences

      
      
      
        
          let preferencesValue: Preferences?
          if let preferencesDocument: Document = source["preferences"] {
            preferencesValue = try Preferences(fromDocument: preferencesDocument)
          } else {
            preferencesValue = nil
          }
        
      
      

      
      

      // initializerkaas:
      try self.init(
          
      )

      
      self.id = idValue
      
      self.name = nameValue
      
      self.preferences = preferencesValue
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
      
      
      
    
      // name: String
      
        var name: VirtualString { return VirtualString(name: keyPrefix + "name") }
      
      
      
      
    
      // preferences: Preferences?
      
      
      
      
        var preferences: Preferences.VirtualInstance { return Preferences.VirtualInstance(keyPrefix: "preferences.") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }


  var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      
        
      

      return result
  }
}



extension House : ConcreteSerializable {
  func pussSerialize() -> Document {
      
      var doc: Document = ["_id": self.id]
      

      
      // id: ObjectId (ObjectId)
      
      
      
      
      // owner: Reference<User, Deny>? (Reference<User, Deny>)
      
      
        doc["owner"] = self.owner?.id
      
      
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
      // Extract all properties
      
      // loop: id

      
      
      
      

      
      let idValue: ObjectId = try Puss.Helpers.requireValue(source["_id"], keyForError: "id")
      
      
      // loop: owner

      
      
        // o the noes it is a reference
        let ownerId: ObjectId? = source["owner"]
        let ownerValue: Reference<User, Deny>?

        
          if let ownerId = ownerId {
              ownerValue = Reference(restoring: ownerId)
          } else {
              ownerValue = nil
          }
        
      
      
      

      
      

      // initializerkaas:
      try self.init(
          
      )

      
      self.id = idValue
      
      self.owner = ownerValue
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
      
      
      
    
      // owner: Reference<User, Deny>?
      
      
      
        var owner: VirtualReference<Reference<User, Deny>.Model, Reference<User, Deny>.DeleteRule> { return VirtualReference(name: keyPrefix + "owner") }
      
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }


  var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
          
            if let ownerValue = self.owner {
          
          result.append(("owner", ownerValue.destinationType, ownerValue.deleteRule, ownerValue.id))
          
            }
          
        
      

      return result
  }
}



extension Preferences : ConcreteSerializable {
  func pussSerialize() -> Document {
      
      var doc = Document()
      

      
      // likesCheese: Bool (Bool)
      
        doc["likesCheese"] = self.likesCheese
      
      
      
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
      // Extract all properties
      
      // loop: likesCheese

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let likesCheeseValue: Bool = try Puss.Helpers.requireValue(source["likesCheese"], keyForError: "likesCheese")
      
      

      
      

      // initializerkaas:
      try self.init(
          
      )

      
      self.likesCheese = likesCheeseValue
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // likesCheese: Bool
      
        var likesCheese: VirtualBool { return VirtualBool(name: keyPrefix + "likesCheese") }
      
      
      
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }


  var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      

      return result
  }
}



extension User : ConcreteSerializable {
  func pussSerialize() -> Document {
      
      var doc: Document = ["_id": self.id]
      

      
      // id: ObjectId (ObjectId)
      
      
      
      
      // email: String (String)
      
        doc["email"] = self.email
      
      
      
      
      // firstName: String? (String)
      
        doc["firstName"] = self.firstName
      
      
      
      
      // lastName: String? (String)
      
        doc["lastName"] = self.lastName
      
      
      
      
      // passwordHash: Data? (Data)
      
        doc["passwordHash"] = self.passwordHash
      
      
      
      
      // registrationDate: Date (Date)
      
        doc["registrationDate"] = self.registrationDate
      
      
      
      
      // preferences: Preferences (Preferences)
      
      
      
        doc["preferences"] = self.preferences.pussSerialize()
      
      
      // pet: Reference<Dog, Cascade> (Reference<Dog, Cascade>)
      
      
        doc["pet"] = self.pet.id
      
      
      
      // boss: Reference<User, Ignore>? (Reference<User, Ignore>)
      
      
        doc["boss"] = self.boss?.id
      
      
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
      // Extract all properties
      
      // loop: id

      
      
      
      

      
      let idValue: ObjectId = try Puss.Helpers.requireValue(source["_id"], keyForError: "id")
      
      
      // loop: email

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let emailValue: String = try Puss.Helpers.requireValue(source["email"], keyForError: "email")
      
      

      
      
      // loop: firstName

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let firstNameValue: String? = source["firstName"]
      
      

      
      
      // loop: lastName

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let lastNameValue: String? = source["lastName"]
      
      

      
      
      // loop: passwordHash

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let passwordHashValue: Data? = source["passwordHash"]
      
      

      
      
      // loop: registrationDate

      
      // The property is a BSON type, so we can just extract it from the document:
      
      let registrationDateValue: Date = try Puss.Helpers.requireValue(source["registrationDate"], keyForError: "registrationDate")
      
      

      
      
      // loop: preferences

      
      
      
        
          let preferencesDocument: Document = try Puss.Helpers.requireValue(source["preferences"], keyForError: "preferences")
          let preferencesValue: Preferences = try Preferences(fromDocument: preferencesDocument)
        
      
      

      
      
      // loop: pet

      
      
        // o the noes it is a reference
        let petId: ObjectId? = source["pet"]
        let petValue: Reference<Dog, Cascade>

        
          petValue = Reference(restoring: try Puss.Helpers.requireValue(petId, keyForError: "pet"))
        
      
      
      

      
      
      // loop: boss

      
      
        // o the noes it is a reference
        let bossId: ObjectId? = source["boss"]
        let bossValue: Reference<User, Ignore>?

        
          if let bossId = bossId {
              bossValue = Reference(restoring: bossId)
          } else {
              bossValue = nil
          }
        
      
      
      

      
      

      // initializerkaas:
      try self.init(
          
          email: emailValue
          
          
      )

      
      self.id = idValue
      
      self.email = emailValue
      
      self.firstName = firstNameValue
      
      self.lastName = lastNameValue
      
      self.passwordHash = passwordHashValue
      
      self.registrationDate = registrationDateValue
      
      self.preferences = preferencesValue
      
      self.pet = petValue
      
      self.boss = bossValue
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
      
      
      
    
      // email: String
      
        var email: VirtualString { return VirtualString(name: keyPrefix + "email") }
      
      
      
      
    
      // firstName: String?
      
        var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") }
      
      
      
      
    
      // lastName: String?
      
        var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") }
      
      
      
      
    
      // passwordHash: Data?
      
        var passwordHash: VirtualData { return VirtualData(name: keyPrefix + "passwordHash") }
      
      
      
      
    
      // registrationDate: Date
      
        var registrationDate: VirtualDate { return VirtualDate(name: keyPrefix + "registrationDate") }
      
      
      
      
    
      // preferences: Preferences
      
      
      
      
        var preferences: Preferences.VirtualInstance { return Preferences.VirtualInstance(keyPrefix: "preferences.") }
      
    
      // pet: Reference<Dog, Cascade>
      
      
      
        var pet: VirtualReference<Reference<Dog, Cascade>.Model, Reference<Dog, Cascade>.DeleteRule> { return VirtualReference(name: keyPrefix + "pet") }
      
      
    
      // boss: Reference<User, Ignore>?
      
      
      
        var boss: VirtualReference<Reference<User, Ignore>.Model, Reference<User, Ignore>.DeleteRule> { return VirtualReference(name: keyPrefix + "boss") }
      
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }


  var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
          
            let petValue = self.pet
          
          result.append(("pet", petValue.destinationType, petValue.deleteRule, petValue.id))
          
        
      
        
          
            if let bossValue = self.boss {
          
          result.append(("boss", bossValue.destinationType, bossValue.deleteRule, bossValue.id))
          
            }
          
        
      

      return result
  }
}




extension Dog : ConcreteModel {
    static let pussCollection = Puss.database["dog"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<Dog> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }
}

extension House : ConcreteModel {
    static let pussCollection = Puss.database["house"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<House> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }
}

extension User : ConcreteModel {
    static let pussCollection = Puss.database["user"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<User> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }
}

