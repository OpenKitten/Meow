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



extension User : ConcreteSerializable {
    func meowSerialize() -> Document {
        return (try? self.meowSerialize(resolvingReferences: false) ) ?? Document()
    }
    
    func meowSerialize(resolvingReferences: Bool) throws -> Document {
        
        var doc: Document = ["_id": self.id]
        
        
        
        
        
        doc["id"] = self.id
        
        doc["email"] = self.email
        
        doc["name"] = self.name
        
        // Variable: name = gender, typeName = Gender?, isComputed = false, isStatic = false, readAccess = internal, writeAccess = internal, annotations = [:], attributes = [:]
        
        // Variable: name = favouriteNumbers, typeName = [Int], isComputed = false, isStatic = false, readAccess = internal, writeAccess = internal, annotations = [:], attributes = [:]
        
        
        return doc
    }
    
    
    convenience init(fromDocument source: Document) throws {
        var source = source
        // Extract all properties
        
        
        
        
        
        // The property is a BSON type, so we can just extract it from the document:
        
        let idValue: ObjectId = try Meow.Helpers.requireValue(ObjectId(source.removeValue(forKey: "id")), keyForError: "id")
        
        
        
        
        
        
        
        // The property is a BSON type, so we can just extract it from the document:
        
        let emailValue: String = try Meow.Helpers.requireValue(String(source.removeValue(forKey: "email")), keyForError: "email")
        
        
        
        
        
        
        
        // The property is a BSON type, so we can just extract it from the document:
        
        let nameValue: String = try Meow.Helpers.requireValue(String(source.removeValue(forKey: "name")), keyForError: "name")
        
        
        
        
        
        
        
        
        let genderValue: Gender?
        
        if let sourceVal = source.removeValue(forKey: "gender") {
            genderValue = try Gender(value: sourceVal)
        } else {
            genderValue = nil
        }
        
        
        
        
        
        
        
        // The property is a BSON type, so we can just extract it from the document:
        
        let favouriteNumbersValue: [Int] = try Meow.Helpers.requireValue([Int](source.removeValue(forKey: "favouriteNumbers")), keyForError: "favouriteNumbers")
        
        
        
        
        // Uses the first existing initializer
        // TODO: Support multiple/more complex initializers
        try self.init(
            
            
            email: emailValue
            
            ,
            
            
            name: nameValue
            
            ,
            
            
            gender: genderValue
            
            
        )
        
        // Sets the other variables
        
        
        
        
        self.id = idValue
        
        
        
        
        self.email = emailValue
        
        
        
        
        self.name = nameValue
        
        
        
        
        self.gender = genderValue
        
        
        
        
        self.favouriteNumbers = favouriteNumbersValue
        
        
    }
    
    
    struct VirtualInstance {
        var keyPrefix: String
        
        
        
        
        // id: ObjectId
        
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
        
        
        
        // email: String
        
        var email: VirtualString { return VirtualString(name: keyPrefix + "email") }
        
        
        
        // name: String
        
        var name: VirtualString { return VirtualString(name: keyPrefix + "name") }
        
        
        
        // gender: Gender?
        
        var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: "gender.") }
        
        
        
        // favouriteNumbers: [Int]
        
        var favouriteNumbers: VirtualArray<VirtualNumber> { return VirtualArray<VirtualNumber>(name: keyPrefix + "favouriteNumbers") }
        
        
        
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
    
    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<User> {
        let query = closure(VirtualInstance())
        return try self.find(query)
    }
    
    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> User? {
        let query = closure(VirtualInstance())
        return try self.findOne(query)
    }
    
    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(query)
    }
    
    static func createIndex(named name: String? = nil, withParameters closure: ((VirtualInstance, IndexSubject) -> ())) throws {
        let indexSubject = IndexSubject()
        closure(VirtualInstance(), indexSubject)
        
        try meowCollection.createIndexes([(name: name ?? "", parameters: indexSubject.makeIndexParameters())])
    }
}


//   extension User : Primitive {
//     public var typeIdentifier: UInt8 {
//       return 0x03
//     }
//
//     public func makeBinary() -> [UInt8] {
//       return self.meowSerialize().makeBinary()
//     }
//   }
//
//   extension User : ResponseRepresentable {
//     public func makeResponse() -> Response {
//       return self.makeExtendedJSON().makeResponse()
//     }
//   }
//









// extension Droplet {
//   public func start(_ mongoURL: String) throws -> Never {
//     let meow = try Meow.init(mongoURL)
//
//
//
//
//           self.get("users", "/") { request in
//
//
//
//
//
//
//
//         // TODO: Reverse isVoid when that works
//            let responseObject = try User.list(
//
//           )
//
//
//
//               return responseObject
//
//
//
//           }
//
//
//           self.get("users", "filtered") { request in
//
//
//
//
//             guard let query = request.query, case .object(let parameters) = query else {
//                 return Response(status: .badRequest)
//             }
//
//
//
//
//
//
//                 guard let email = parameters["email"]?.string else {
//                   return Response(status: .badRequest)
//                 }
//
//
//
//
//
//
//
//
//         // TODO: Reverse isVoid when that works
//            let responseObject = try User.find(
//
//               email: email
//
//
//           )
//
//
//
//               return try Meow.Helpers.requireValue(responseObject, keyForError: "")
//
//
//
//           }
//
//
//           self.get("users", "containing") { request in
//
//
//
//
//             guard let query = request.query, case .object(let parameters) = query else {
//                 return Response(status: .badRequest)
//             }
//
//
//
//
//
//
//                 guard let email = parameters["email"]?.string else {
//                   return Response(status: .badRequest)
//                 }
//               
//             
//           
//         
//
//         
//
//         
//         // TODO: Reverse isVoid when that works
//            let responseObject = try User.find(
//             
//               email: email
//               
//             
//           )
//
//           
//             
//               return try Meow.Helpers.requireValue(responseObject, keyForError: "")
//             
//           
//         
//           }
//       
//         
//           self.delete("users", User.self, "/") { request, model in
//         
//
//         
//
//         
//
//         
//         // TODO: Reverse isVoid when that works
//            try model.remove(
//             
//           )
//
//             
//               return Response(status: .ok)
//             
//           
//           }
//       
//     
//     self.run()
//   }
// }
