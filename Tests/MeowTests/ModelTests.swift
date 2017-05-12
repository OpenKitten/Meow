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
@testable import MeowSample

class ModelTests : XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost")
    }
    
    func testFind() throws {
        try Tiger.remove()
        
        let tiger = Tiger(breed: Breed(name: "Normal"))
        
        try tiger.save()
        
        let tigerCount = try Tiger.count { tiger in
            return tiger.breed.name == "Normal"
        }
        
        XCTAssertEqual(tigerCount, 1)
    }
}
