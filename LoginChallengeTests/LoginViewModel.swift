import APIServices
import Combine
import Entities
import Logging
import UseCases

@MainActor
final class LoginViewModel: ObservableObject {
    // String(reflecting:) はモジュール名付きの型名を取得するため。
    private let logger: Logger = .init(label: String(reflecting: LoginViewModel.self))
    
    // 副作用を持たないのでDIしなくても良い。
    private let errorHandle = LoginErrorHandling()
    private let validation = LoginValidation()

    /// ID/パスワードのテキストフィールドに入力可能か否か
    @Published private(set) var canInput = true
    /// ログインボタンが有効か否か
    @Published private(set) var enableLoginButton = false
    /// ローディング状態
    @Published private(set) var loadingState: LoadingState = .idle {
        didSet {
            switch loadingState {
            case .idle:
                canInput = true
                enableLoginButton = validation(id: id, password: password)
            case .loading:
                canInput = false
                enableLoginButton = false
            case .loaded:
                // この VC から遷移するのでボタンの押下受け付けは再開しない。
                // 遷移アニメーション中に処理が実行されることを防ぐ。
                return
            case .failed:
                canInput = true
                enableLoginButton = validation(id: id, password: password)
            }
        }
    }
    /// 入力されたID
    var id = "" {
        didSet {
            enableLoginButton = validation(id: id, password: password)
        }
    }
    /// 入力されたパスワード
    var password = "" {
        didSet {
            enableLoginButton = validation(id: id, password: password)
        }
    }
    
    /// ログイン実行
    func login() async {
        // 処理が二重に実行されるのを防ぐ。
        guard enableLoginButton else { return }
        
        /// 念の為バリデーションしている
        guard validation(id: id, password: password) else { return }
        
        // 処理中は入力とボタン押下を受け付けない。
        canInput = false
        enableLoginButton = false
        
        loadingState = .loading
        
        do {
            try await AuthService.logInWith(id: id, password: password)
            loadingState = .loaded
        } catch {
            let message = errorHandle(error)
            loadingState = .failed(error: error, message: message)
        }
    }
}
