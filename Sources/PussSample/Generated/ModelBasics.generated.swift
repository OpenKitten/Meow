// Generated using Sourcery 0.5.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Puss
import Foundation


extension User : ConcreteModel {
    static let pussCollection = Puss.database["user"]

    func pussSerialize() -> Document {
        var doc: Document = ["_id": self.id]

        
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
        
        

        return doc
    }

    convenience init(fromDocument source: Document) throws {
        // Extract all properties
        
        
        let emailValue: String = try Puss.Helpers.requireValue(source["email"], keyForError: "email")
        
        
        
        let firstNameValue: String? = source["firstName"]
        
        
        
        let lastNameValue: String? = source["lastName"]
        
        
        
        let passwordHashValue: Data? = source["passwordHash"]
        
        
        
        let registrationDateValue: Date = try Puss.Helpers.requireValue(source["registrationDate"], keyForError: "registrationDate")
        
        

        self.init(
            
            email: emailValue
            
        )

        
        self.email = emailValue
        
        self.firstName = firstNameValue
        
        self.lastName = lastNameValue
        
        self.passwordHash = passwordHashValue
        
        self.registrationDate = registrationDateValue
        

        //Method: parameters = [Parameter: argumentLabel = email, name = email, typeName = String, type = nil, ], shortName = init, selectorName = init(email:), returnTypeName = , accessLevel = internal, isStatic = false, isClass = false, isInitializer = true, isFailableInitializer = false, annotations = [:], 

    }
}

