//
//  BaseModelTests.swift
//  Meow
//
//  Created by Joannis Orlandos on 12/05/2017.
//
//

import Foundation
import XCTest
import Meow
import MeowSample

class ModelTests : XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost")
    }
    
    func testFind() throws {
        
    }
}
