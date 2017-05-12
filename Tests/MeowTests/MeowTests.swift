//import XCTest
//@testable import Meow
//
//
//class MeowTests: XCTestCase {
//    override func setUp() {
//        try! Meow.init("mongodb://localhost:27017/meow")
//        try! Meow.database.drop()
//    }
//
//    static var allTests : [(String, (MeowTests) -> () throws -> Void)] {
//        return [
//            ("testExample", testExample),
//        ]
//    }
//}
//
//final class Group: Model {
//    let name: String
//    
//    init(name: String) {
//        self.name = name
//    }
//}
//
//final class User: Model {
//    // sourcery:begin: unique
//    var username: String
//    var email: String
//    // sourcery:end
//    
//    var password: String
//    var age: Int?
//    var gender: Gender?
//    var details: Details?
//    var group: Group
//    var preferences = [Preference]()
//    var extraPreferences: [Preference]?
//    var unnamedTuple: (String,String,Int) = ("Example", "Other example", 4)
//    
//    // sourcery: permissions = "anonymous"
//    init(username: String, email: String, password: String, age: Int? = nil, gender: Gender? = nil) {
//        self.username = username
//        self.email = email
//        self.password = password
//        self.age = age
//        self.gender = gender
//    }
//    
//    // sourcery:inline:User.Meow
//      init(meowDocument source: Document) throws {
//          self._id = try Meow.Helpers.requireValue(ObjectId(source["_id"]), keyForError: "_id")
//        
//          self.username = try Meow.Helpers.requireValue(String(source["username"]), keyForError: "username")  /* String */ 
//          self.email = try Meow.Helpers.requireValue(String(source["email"]), keyForError: "email")  /* String */ 
//          self.password = try Meow.Helpers.requireValue(String(source["password"]), keyForError: "password")  /* String */ 
//          self.age = Int(source["age"])  /* Int? */ 
//          self.gender = try Gender(meowValue: source["gender"])  /* Gender? */ 
//          self.details = try Details(meowValue: source["details"])  /* Details? */ 
//          self.preferences = try Meow.Helpers.requireValue(meowReinstantiatePreferenceArray(from: source["preferences"]), keyForError: "preferences")  /* [Preference] */ 
//          self.extraPreferences = try meowReinstantiatePreferenceArray(from: source["extraPreferences"])  /* [Preference]? */ 
//          self.unnamedTuple = try Meow.Helpers.requireValue(meowDeserializeTupleOf0StringAnd1StringAnd2Int(source["unnamedTuple"]), keyForError: "unnamedTuple")  /* (String,String,Int) */ 
//      }
//      
//        var _id = ObjectId()
//    //sourcery:end
//}
//
//enum Gender {
//    case male, female
//}
//
//enum Preference : String {
//    case swift, mongodb, linux, macos
//}
//
//struct Details {
//    var firstName: String?
//    var lastName: String?
//
//    var address: (streetName: String?, number: Int, city: String, houseGender: Gender)?
//
//    init() {}
//}
