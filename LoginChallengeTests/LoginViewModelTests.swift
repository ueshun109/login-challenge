import Combine
import XCTest
@testable import LoginChallenge

@MainActor
class LoginViewModelTests: XCTestCase {
    private var viewModel: LoginViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    @MainActor override func setUp() {
        super.setUp()
        self.viewModel = LoginViewModel()
    }
    
    func testLoginButton() {
        XCTContext.runActivity(named: "ログインボタンの状態") { _ in
            XCTContext.runActivity(named: "ID/パスワードともに未入力") { _ in
                viewModel.id = ""
                viewModel.password = ""
                XCTAssertFalse(viewModel.enableLoginButton)
            }
            XCTContext.runActivity(named: "IDのみ入力済み") { _ in
                viewModel.id = "id"
                viewModel.password = ""
                XCTAssertFalse(viewModel.enableLoginButton)
            }
            XCTContext.runActivity(named: "パスワードのみ入力済み") { _ in
                viewModel.id = ""
                viewModel.password = "password"
                XCTAssertFalse(viewModel.enableLoginButton)
            }
            XCTContext.runActivity(named: "ID/パスワードともに入力済み") { _ in
                viewModel.id = "id"
                viewModel.password = "password"
                XCTAssertTrue(viewModel.enableLoginButton)
            }
        }
    }
    
    // 依存しているAuthServiceの現状コードだと、1/2で失敗してしまう。
    // AuthServiceは副作用を持つコードなので、ViewModelに外部からDIできるようにしたい。
    func testLoginSuccessful() async {
        viewModel.id = "koher"
        viewModel.password = "1234"
        await viewModel.login()
        XCTAssertFalse(viewModel.canInput)
        XCTAssertFalse(viewModel.enableLoginButton)
        if case .loaded = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Loading state must be loaded.")
        }
    }
    
    func testLoginFailure() async {
        viewModel.id = "id"
        viewModel.password = "password"
        await viewModel.login()
        XCTAssertTrue(viewModel.canInput)
        XCTAssertTrue(viewModel.enableLoginButton)
        if case .failed = viewModel.loadingState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Loading state must be failed.")
        }
    }
}
