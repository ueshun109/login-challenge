import XCTest
import Entities
@testable import LoginChallenge

class LoginErrorHandlingTests: XCTestCase {
    private let errorHandle = LoginErrorHandling()
    
    func testLoginError() {
        let error = errorHandle(LoginError())
        let expectedTitle = "ログインエラー"
        let expectedMessage = "IDまたはパスワードが正しくありません。"
        XCTAssertEqual(error.title, expectedTitle)
        XCTAssertEqual(error.message, expectedMessage)
    }
    
    func testNetworkError() {
        let error = errorHandle(NetworkError(cause: GeneralError(message: "Timeout.")))
        let expectedTitle = "ネットワークエラー"
        let expectedMessage = "通信に失敗しました。ネットワークの状態を確認して下さい。"
        XCTAssertEqual(error.title, expectedTitle)
        XCTAssertEqual(error.message, expectedMessage)
    }

    func testServerError() {
        let error = errorHandle(ServerError.internal(cause: GeneralError(message: "Real limit exceeded")))
        let expectedTitle = "サーバーエラー"
        let expectedMessage = "しばらくしてからもう一度お試し下さい。"
        XCTAssertEqual(error.title, expectedTitle)
        XCTAssertEqual(error.message, expectedMessage)
    }
    
    func testSystemError() {
        let error = errorHandle(GeneralError(message: "System error."))
        let expectedTitle = "システムエラー"
        let expectedMessage = "エラーが発生しました。"
        XCTAssertEqual(error.title, expectedTitle)
        XCTAssertEqual(error.message, expectedMessage)
    }
}
