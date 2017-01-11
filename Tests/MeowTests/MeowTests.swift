import XCTest
@testable import Meow
import Foundation

final class House : Model {
    var id = ObjectId()
    
    var owner: Reference<User, Deny>?
    var family: [Reference<User, Cascade>] = []
}

final class User : Model {
    var id = ObjectId()
    
    var email: String
    var firstName: String?
    var lastName: String?
    var passwordHash: Data?
    var registrationDate: Date
    var preferences = Preferences()
    var pet: Reference<Dog, Cascade>
    var boss: Reference<User, Ignore>?
    
    init(email: String) throws {
        self.email = email
        self.registrationDate = Date()
        let pet = Dog()
        try pet.save()
        self.pet = Reference(pet)
    }
}

final class Preferences : Embeddable {
    var likesCheese: Bool = false
}

final class Dog : Model {
    var id = ObjectId()
    var name: String = "Fluffy"
    
    var preferences: Preferences?
}

class MeowTests: XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost/meow")
        try! Meow.database.drop()
    }
    
    func testExample() throws {
        let boss = try User(email: "harriebob@example.com")
        boss.firstName = "Harriebob"
        boss.lastName = "Konijn"
        XCTAssertEqual(try User.count(), 0)
        try boss.save()
        XCTAssertEqual(try User.count(), 1)
        
        let bossHouse = House()
        bossHouse.owner = Reference(boss)
        try bossHouse.save()
        
        XCTAssertThrowsError(try bossHouse.delete())
        
        guard let house = try House.findOne(matching: {
            $0.owner == boss
        }) else {
            XCTFail()
            return
        }
        
        let wife = try User(email: "wife@family.example.com")
        let son = try User(email: "son@family.example.com")
        let daughter = try User(email: "daughter@family.example.com")
        
        try wife.save()
        try son.save()
        try daughter.save()
        
        house.family = [Reference(wife), Reference(son), Reference(daughter)]
        
        try house.save()
        
        guard try House.findOne(matching: { h in
            return h.family.contains(daughter)
        }) != nil else {
            XCTFail()
            return
        }
        
        guard try House.findOne(matching: { h in
            return !(!h.family.contains(daughter))
        }) != nil else {
            XCTFail()
            return
        }
        
        guard try House.findOne(matching: { h in
            return !(!h.family.contains(daughter)) && h.family.contains(son)
        }) != nil else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(house.id, bossHouse.id)
        XCTAssertEqual(try house.owner?.resolve().email, boss.email)
        
        let employee = try User(email: "joannis@orlandos.nl")
        let employee2 = try User(email: "i@robbertbrandsma.nl")
        
        employee.boss = Reference(boss)
        employee2.boss = Reference(boss)
        
        employee.firstName = "Joannis"
        employee.lastName = "Orlandos"
        
        employee2.firstName = "Robbert"
        employee2.lastName = "Brandsma"
        
        employee.preferences.likesCheese = true
        employee2.preferences.likesCheese = false
        
        guard try House.findOne(matching: { h in
            return h.family.contains(son) || (h.family.contains(employee) && h.family.contains(employee2))
        }) != nil else {
            XCTFail()
            return
        }
        
        if try House.findOne(matching: { h in
            return h.family.contains(employee2)
        }) != nil {
            XCTFail()
            return
        }
        
        if try House.findOne(matching: { h in
            return !h.family.contains(daughter)
        }) != nil {
            XCTFail()
            return
        }
        
        try employee.save()
        try employee2.save()
        
        XCTAssertEqual(try User.count { $0.preferences.likesCheese == true }, 1)
        XCTAssertEqual(try User.count { $0.preferences.likesCheese == false }, 5)
    }


    static var allTests : [(String, (MeowTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
