import XCTest
@testable import CodableWebSocket

final class CodableWebSocketTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CodableWebSocket().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
