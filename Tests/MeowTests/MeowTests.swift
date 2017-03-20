import XCTest
@testable import Meow


class MeowTests: XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost:27017/meow")
        try! Meow.database.drop()
    }
    
    func testExample() throws {
        let user0 = User(username: "piet", password: "123", age: 20, gender: .male)
        let user1 = User(username: "henk", password: "321", age: 20, gender: .male)
        let user2 = User(username: "klaas", password: "12345", age: 16, gender: .female)
        let user3 = User(username: "harrie", password: "bob", age: 24, gender: .male)
        let user4 = User(username: "bob", password: "harrie", age: 42, gender: .male)
        
        try user0.save()
        try user1.save()
        try user2.save()
        try user3.save()
        try user4.save()
        
        XCTAssertEqual(try User.count { user in
            return user.username == "piet" || user.password == "321"
        }, 2)
        
        XCTAssertEqual(try User.count { user in
            return user.username == "piet" || user.password == "123"
            }, 1)
        
        XCTAssertEqual(try User.count { user in
            return user.username == "harrie" || user.password == "harrie"
            }, 2)
        
        XCTAssertEqual(try User.count { user in
            return user.username.hasPrefix("h")
            }, 2)
        
        XCTAssertEqual(try User.count { user in
            return user.gender == .female
            }, 1)
        
        XCTAssertEqual(try User.count { user in
            return user.gender == .male
            }, 4)
        
        XCTAssertEqual(try User.count { user in
            return user.age >= 20
            }, 4)
        
        XCTAssertEqual(try User.count { user in
            return user.age > 20
            }, 2)
        
        XCTAssertEqual(try User.count { user in
            return user.age < 20
            }, 1)
        
        XCTAssertEqual(try User.count(), 5)
        
        XCTAssertEqual(try User.findOne { $0.username == "harrie" }?.password, "bob")
        
//        try user0.delete()
//        try user1.delete()
//        try user2.delete()
//        try user3.delete()
//        try user4.delete()
    }

//    func test

    static var allTests : [(String, (MeowTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}


final class User: Model {
    var id = ObjectId()
    
    var username: String
    var password: String
    var age: Int?
    var gender: Gender?
    var details: Details?
    var preferences = [Preference]()
    var extraPreferences: [Preference]?
    
    init(username: String, password: String, age: Int? = nil, gender: Gender? = nil) {
        self.username = username
        self.password = password
        self.age = age
        self.gender = gender
    }
}

enum Gender: String, Embeddable {
    case male, female
}

enum Preference: String, Embeddable {
    case swift, mongodb, linux, macos
}

struct Details: Embeddable {
    var firstName: String?
    var lastName: String?
}
