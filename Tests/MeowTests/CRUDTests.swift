
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
    
    override func tearDown() {
        if Meow.pool.count != 0 {
            XCTFail("After the tests the pool count must be 0, else there is a reference loop somewhere.")
        }
    }
    
    func testDatabaseValidation() throws {
        _ = Breed(name: "test")
        
        XCTAssertEqual(try Meow.validateDatabaseIntegrity(types: [Breed.self]).count, 0)
        
        try Breed.collection.insert([
            "_id": ObjectId(),
            "name": 3
        ])
        
        XCTAssertNotEqual(try Meow.validateDatabaseIntegrity(types: [Breed.self]).count, 0)
    }
    
//    func testSort() throws {
//        let sort: TypesafeSort<Tiger> = [
//            \Tiger.breed: .ascending
//        ]
//        
//        XCTAssertEqual(sort.sort.makeDocument(), ["breed": Int32(1)])
//        
//        _ = Breed(name: "A")
//        _ = Breed(name: "B")
//        _ = Breed(name: "C")
//        _ = Breed(name: "D")
//        _ = Breed(name: "E")
//        _ = Breed(name: "F")
//        
//        var baseOrder = ["A", "B", "C", "D", "E", "F"]
//        
//        for (offset, breed) in try Breed.find(sortedBy: [\Breed.name: .ascending]).enumerated() {
//            XCTAssertEqual(breed.name, baseOrder[offset])
//        }
//        
//        baseOrder = baseOrder.reversed()
//        
//        for (offset, breed) in try Breed.find(sortedBy: [\Breed.name: .descending]).enumerated() {
//            XCTAssertEqual(breed.name, baseOrder[offset])
//        }
//    }
    
    func testSave() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        requireUpdate = true
        try tigerBreed.save()
        
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
//        XCTAssertNotNil(try Tiger.findOne(\Tiger._id == tiger._id))
        
        try tiger.delete()
        
        //        XCTAssertNil(try Tiger.findOne(\Tiger._id == tiger._id))
        XCTAssertNil(try Tiger.findOne("_id" == tiger._id))
    }
    
    func testRelationships() throws {
        let breed = Breed(name: "superbreed")
        
        try breed.save()
        
        let tiger = Tiger(breed: breed)
        
        XCTAssert(tiger.breed.reference == breed._id)
        
        let resolvedSameBreed = try tiger.breed.resolve()
        
        XCTAssertEqual(resolvedSameBreed._id, breed._id)
        XCTAssertEqual(Reference(to: breed), tiger.breed)
        XCTAssert(breed._id == Reference(to: breed).reference)
        
        let breed2 = try Reference<Breed>(to: breed._id).resolve()
        XCTAssert(breed._id == breed2._id)
        XCTAssert(Reference(to: breed) == tiger.breed)
    }
    
    func testCount() throws {
        let tigerBreed = Breed(name: "kaas")
        try tigerBreed.save()
        
        try Tiger(breed: tigerBreed).save()
        try Tiger(breed: tigerBreed).save()
        try Tiger(breed: tigerBreed).save()
        try Tiger(breed: Breed(name: "meep")).save()
        
        XCTAssertEqual(try Tiger.count("breed" == tigerBreed._id), 3)
        XCTAssertEqual(try Tiger.count("breed" != tigerBreed._id), 1)
//        XCTAssertEqual(try Tiger.count(\Tiger.breed.name == "kaas"), 3)
//        XCTAssertEqual(try Tiger.count(\Tiger.breed.name == "meep"), 1)
    }
    
    func testDeleteBulk() throws {
        try testFindBulk()

        let tigerBreed = try Breed.findOne()

        //try Tiger.remove(\Tiger.breed == tigerBreed, limitedTo: 2)

        try Tiger.remove("breed" == tigerBreed?._id, limitedTo: 2)
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

//        let results = try Tiger.find(\Tiger.breed == tigerBreed, limitedTo: 10)
        let results = try Tiger.find("breed" == tigerBreed._id, limitedTo: 10)
        
        for _ in results {
            counter += 1
        }
    }
    
    func testFindOne() throws {
        let tigerBreed = Breed(name: "Normal")
        try tigerBreed.save()
        
        let tiger = Tiger(breed: tigerBreed)
        try tiger.save()
        
        let tigerCount = Array(try Tiger.find("breed" == tigerBreed._id)).count
        XCTAssertEqual(tigerCount, 1)
        
//        let tigerCount = Array(try Tiger.find(\Tiger.breed.name == "Normal")).count
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
