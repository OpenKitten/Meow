
//
//  BaseModelTests.swift
//  Meow
//
//  Created by Joannis Orlandos on 12/05/2017.
//
//

import Foundation
import XCTest
@testable import Meow

func fsync() throws {
    try Meow.database.server.fsync(blocking: true)
}

fileprivate var requireUpdate: Bool? = nil

class CRUDTests : XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost/meowtests")
        try! Meow.database.drop()
    }
    
    func testDatabaseValidation() throws {
        _ = Breed(name: "test")
        
        XCTAssertEqual(try Meow.validateDatabaseIntegrity().count, 0)
        
        try Breed.collection.insert([
            "_id": ObjectId(),
            "name": 3
        ])
        
        XCTAssertNotEqual(try Meow.validateDatabaseIntegrity().count, 0)
    }
    
    func testSort() throws {
        let sort: [Tiger.Key : SortOrder] = [
            .breed: .ascending
        ]
        
        XCTAssertEqual(sort.makeSort().makeDocument(), ["breed": Int32(1)])
        
        _ = Breed(name: "A")
        _ = Breed(name: "B")
        _ = Breed(name: "C")
        _ = Breed(name: "D")
        _ = Breed(name: "E")
        _ = Breed(name: "F")
        
        var baseOrder = ["A", "B", "C", "D", "E", "F"]
        
        for (offset, breed) in try Breed.find(sortedBy: [.name: .ascending], { _ in Query() }).enumerated() {
            XCTAssertEqual(breed.name, baseOrder[offset])
        }
        
        baseOrder = baseOrder.reversed()
        
        for (offset, breed) in try Breed.find(sortedBy: [.name: .descending], { _ in Query() }).enumerated() {
            XCTAssertEqual(breed.name, baseOrder[offset])
        }
    }
    
    func testSave() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        requireUpdate = true
        try tigerBreed.save(force: true)
        
        requireUpdate = false
        try tigerBreed.save()
        
        requireUpdate = nil
    }
    
    func testDelete() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        let tiger = Tiger(breed: tigerBreed)
        try tiger.save()
        
        XCTAssertNotNil(try Tiger.findOne("_id" == tiger._id))
        
        try tiger.delete()
        
        XCTAssertNil(try Tiger.findOne("_id" == tiger._id))
    }
    
    func testDeallocation() throws {
        var cat: Cat? = Cat(name: "MoopCat", breed: "SuperCat", bestFriend: nil, family: [])
        cat?.social = SocialMedia.facebook(name: "MoopCat")
        
        XCTAssertEqual(try Cat.count({ cat in
            return cat.social == .facebook(name: "MoopCat")
        }), 0)
        
        cat = nil
        
        XCTAssertEqual(try Cat.count({ cat in
            return cat.social == .facebook(name: "MoopCat")
        }), 1)
    }
    
    func testRelationships() throws {
        let breed = Breed(name: "superbreed")
        
        try breed.save()
        
        let tiger = Tiger(breed: breed)
        
        XCTAssert(tiger.breed == breed)
        XCTAssert(tiger.sameBreed == breed)
        XCTAssert(tiger.sameBreed == tiger.breed)
        
        let resolvedSameBreed = try *tiger.sameBreed
        
        XCTAssertEqual(resolvedSameBreed._id, breed._id)
        XCTAssertEqual(Reference(to: breed), tiger.sameBreed)
        XCTAssert(breed == Reference(to: breed))
        
        let breed2 = try Reference<Breed>(restoring: Reference(to: breed).serialize(), key: "").resolve()
        XCTAssert(breed == breed2)
        XCTAssert(Reference(to: breed) == tiger.sameBreed)
        
        XCTAssertEqual(tiger.sameBreed.databaseIdentifier, breed._id)
        
        XCTAssert(Tiger.collection.model == Tiger.self)
    }
    
    func testEnums() throws {
        let cat = Cat(name: "MoopCat", breed: "SuperCat", bestFriend: nil, family: [])
        cat.social = SocialMedia.facebook(name: "MoopCat")
        try cat.save()
        
        XCTAssertEqual(try Cat.count({ cat in
            return cat.social == .facebook(name: "MoopCat")
        }), 1)
        
        XCTAssertEqual(try Cat.count({ cat in
            return cat.social == .twitter(handle: "MoopCat")
        }), 0)
        
        XCTAssertEqual(Numbers.two.serialize() as? Int, 2)
    }
    
    func testCount() throws {
        let tigerBreed = Breed(name: "kaas")
        try tigerBreed.save()
        
        _ = Tiger(breed: tigerBreed)
        _ = Tiger(breed: tigerBreed)
        _ = Tiger(breed: tigerBreed)
        _ = Tiger(breed: Breed(name: "meep"))
        
        XCTAssertEqual(try Tiger.count { $0.breed.name == "kaas" }, 3)
        XCTAssertEqual(try Tiger.count { $0.breed.name == "meep" }, 1)
    }
    
    func testDeleteBulk() throws {
        try testFindBulk()
        
        let tigerBreed = try Breed.findOne()
        
        try Tiger.remove(limitedTo: 2) { tiger in
            return tiger.breed == tigerBreed
        }
        
        XCTAssertEqual(try Tiger.count(), 2)
    }
    
    func testFindBulk() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        for _ in 0..<10 {
            let tiger = Tiger(breed: tigerBreed)
            try tiger.save()
        }
        
        try fsync()
        
        var counter = 0
        
        for _ in try Tiger.find() {
            counter += 1
        }
        
        XCTAssertEqual(counter, 10)
        counter = 0
        
        for _ in try Tiger.find(limitedTo: 7) {
            counter += 1
        }
        
        XCTAssertEqual(counter, 7)
        counter = 0
        
        try Tiger.remove(limitedTo: 6)
        try fsync()
        
        XCTAssertEqual(try Tiger.count(), 4)
        
        for _ in try Tiger.find(limitedTo: 10) {
            counter += 1
        }
        
        XCTAssertEqual(counter, 4)
        
        let results = try Tiger.find(limitedTo: 10) { $0.breed == tigerBreed }
        
        for _ in results {
            counter += 1
        }
    }
    
    func testFindOne() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        let tiger = Tiger(breed: tigerBreed)
        try tiger.save()
        
        var tigerCount = Array(try Tiger.find { tiger in
            return tiger.breed.name == "Normal"
        }).count
        
        XCTAssertEqual(tigerCount, 1)
        
        let catReference = CatReferencing(cat: tiger)
        try catReference.save()
        
        let catReference2 = CatReferencing(cat: tiger)
        try catReference2.save()
        
        let tigerBreed2 = Breed(name: "Normal")
        try tigerBreed2.save()
        
        let otherTiger = Tiger(breed: tigerBreed2)
        try otherTiger.save()
        
        let catReference3 = CatReferencing(cat: otherTiger)
        try catReference.save()
        
        XCTAssertEqual(tiger._id, tiger.databaseIdentifier)
        
        XCTAssert(Meow.pool.isPooled(tiger))
        
        var sameTiger = try Tiger.findOne()
        
        func testSameTiger() {
            XCTAssert(sameTiger?.breed == tigerBreed)
            XCTAssert(tiger == sameTiger)
            XCTAssertEqual(tiger.hashValue, sameTiger?.hashValue)
        }
        
        testSameTiger()
        
        sameTiger = try Tiger.findOne("_id" == tiger._id)
        testSameTiger()
        
        sameTiger = try Tiger.findOne("breed" == tigerBreed._id)
        testSameTiger()
        
        sameTiger = try Tiger.findOne { $0.breed._id == tigerBreed._id }
        testSameTiger()
        
        sameTiger = try Tiger.findOne { $0.breed == tigerBreed }
        testSameTiger()
        
        sameTiger = try Tiger.findOne { $0._id == tiger._id }
        testSameTiger()
        
//        sameTiger = try Tiger.findOne { $0.singleBreeds.contains(tigerBreed) }
//        testSameTiger()
//        
//        sameTiger = try Tiger.findOne { $0.sameSingleBreeds.contains(Reference(to: tigerBreed)) }
//        testSameTiger()
//        
//        _ = CatReferencing(cat: tiger)
//        
//        let referenceCount = try CatReferencing.count { $0.cat.breed.name == "Normal" }
//        
//        XCTAssertEqual(referenceCount, 1)
        
        let otherBreed = Breed(name: "Special")
        
        sameTiger?.breed = otherBreed
        XCTAssert(tiger == sameTiger)
        XCTAssertEqual(tiger.hashValue, sameTiger?.hashValue)
        XCTAssert(sameTiger?.breed == tiger.breed)
        XCTAssert(tiger.breed == otherBreed)
        XCTAssert(sameTiger?.breed == otherBreed)
        
        sameTiger = try Tiger.findOne { $0._id == ObjectId() }
        XCTAssertNil(sameTiger)
    }
    
    func testKeyStrings() {
        XCTAssertEqual(Tiger.Key._id.keyString, "_id")
        XCTAssertEqual(Tiger.Key.breed.keyString, "breed")
        
        let string = "myKey"
        let oid = ObjectId()
        
        XCTAssertEqual(string, string.keyString)
        XCTAssertEqual(oid.keyString, oid.hexString)
        
        XCTAssertEqual(try Tiger.recursiveKeysWithReferences(chainedFrom: []).map { $0.0 }, [Tiger.Key.breed.keyString])
    }
    
    func testNewFrom() throws {
        let document: Document = ["name": "OpenKitten-unittest-breed-\(Date().timeIntervalSince1970)", "kaas": ["kaas", "kaas", "kaas"]]
        let breed = try Breed(newFrom: document)
        
        // after newFrom, the object should be saved already
        XCTAssert(try Breed.findOne("name" == document["name"]) === breed)
    }
}

extension Breed {
    public func didSave(wasUpdated: Bool) throws {
        if let requireUpdate = requireUpdate {
            XCTAssertEqual(requireUpdate, wasUpdated)
        }
        
        try fsync()
    }
}
