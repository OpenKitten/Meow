// Generated using Sourcery 0.5.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Puss
import Foundation


extension Preferences : ConcreteModel {
    static let pussCollection = Puss.database["preferences"]

    func pussSerialize() -> Document {
        var doc: Document = ["_id": self.id]

        
        // id: ObjectId (ObjectId)
        
        
        // likesCheese: Bool (Bool)
        
        doc["likesCheese"] = self.likesCheese
        
        

        return doc
    }

    convenience init(fromDocument source: Document) throws {
        // Extract all properties
        
        // loop: id

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let idValue: ObjectId = try Puss.Helpers.requireValue(source["id"], keyForError: "id")
        
        
        
        // loop: likesCheese

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let likesCheeseValue: Bool = try Puss.Helpers.requireValue(source["likesCheese"], keyForError: "likesCheese")
        
        
        

        self.init(
            
        )

        
        self.id = idValue
        
        self.likesCheese = likesCheeseValue
        
    }

    var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
        var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
        _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

        
          
        
          
        

        return result
    }
}

extension User : ConcreteModel {
    static let pussCollection = Puss.database["user"]

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
        
        
        // preferences: Reference<Preferences, Cascade>? (Reference<Preferences, Cascade>)
        
        

        return doc
    }

    convenience init(fromDocument source: Document) throws {
        // Extract all properties
        
        // loop: id

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let idValue: ObjectId = try Puss.Helpers.requireValue(source["id"], keyForError: "id")
        
        
        
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

        
        
          // o the noes it is a reference
          let preferencesId: ObjectId? = source["preferences"]
          let preferencesValue: Reference<Preferences, Cascade>?

          
            if let preferencesId = preferencesId {
                preferencesValue = Reference(restoring: preferencesId)
            } else {
                preferencesValue = nil
            }
          
        
        
        

        self.init(
            
            email: emailValue
            
            
        )

        
        self.id = idValue
        
        self.email = emailValue
        
        self.firstName = firstNameValue
        
        self.lastName = lastNameValue
        
        self.passwordHash = passwordHashValue
        
        self.registrationDate = registrationDateValue
        
        self.preferences = preferencesValue
        
    }

    var pussReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
        var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
        _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

        
          
        
          
        
          
        
          
        
          
        
          
        
          
            
              if let preferencesValue = self.preferences {
            
            result.append(("preferences", preferencesValue.destinationType, preferencesValue.deleteRule, preferencesValue.id))
            
              }
            
          
        

        return result
    }
}

