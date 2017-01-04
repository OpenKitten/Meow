import XCTest
@testable import Puss

class PussTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Puss().text, "Hello, World!")
    }


    static var allTests : [(String, (PussTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
