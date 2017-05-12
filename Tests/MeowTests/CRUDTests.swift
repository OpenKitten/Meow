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
    
    func testDeleteBulk() throws {
        try testFindBulk()
        
        let tigerBreed = try Breed.findOne()
        
        try Tiger.remove(limitedTo: 2) {
            $0.breed == tigerBreed
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
        
        var tigerCount = try Tiger.count { tiger in
            return tiger.breed.name == "Normal"
        }
        
        XCTAssertEqual(tigerCount, 1)
        
        tigerCount = try Tiger.count { tiger in
            return tiger.breed == tigerBreed
        }
        
        XCTAssertEqual(tigerCount, 1)
        
        var sameTiger = try Tiger.findOne()
        
        func testSameTiger() {
            XCTAssert(sameTiger?.breed == tigerBreed)
            XCTAssert(tiger == sameTiger)
            XCTAssertEqual(tiger.hashValue, sameTiger?.hashValue)
        }
        
        testSameTiger()
        
        sameTiger = try Tiger.findOne("_id" == tiger._id)
        testSameTiger()
        
        sameTiger = try Tiger.findOne("breed.$id" == tigerBreed._id)
        testSameTiger()
        
        sameTiger = try Tiger.findOne { $0._id == tiger._id }
        testSameTiger()
        
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
