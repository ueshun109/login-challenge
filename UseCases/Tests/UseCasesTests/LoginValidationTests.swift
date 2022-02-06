import XCTest
@testable import UseCases

class LoginValidationTests: XCTestCase {
    private let validate = LoginValidation()
    
    func testEmptyID() {
        let result = validate(id: "", password: "password")
        XCTAssertFalse(result, "ID must be entered.")
    }
    
    func testEmptyPassword() {
        let result = validate(id: "id", password: "")
        XCTAssertFalse(result, "Pasword must be entered.")
    }
    
    func testEnteredIdAndPassword() {
        let result = validate(id: "id", password: "password")
        XCTAssertTrue(result)
    }
}
