import APIServices
import Entities
import Logging
import SwiftUI
import UseCases

@MainActor
final class HomeViewModel: ObservableObject {
    private let logger: Logger = .init(label: String(reflecting: HomeViewModel.self))
    // 副作用を持たないのでDIしなくても良い。
    private let errorHandle = HomeErrorHandling()
    
    var error: ErrorMessage? {
        if case .failed(_, let message) = loadingState {
            return message
        } else {
            return nil
        }
    }
    
    /// アラートダイアログの表示フラグ
    @Published var presentsAuthenticationErrorAlert = false
    @Published var presentsNetworkErrorAlert = false
    @Published var presentsServerErrorAlert = false
    @Published var presentsSystemErrorAlert = false
    
    /// ログアウト可能か否かを表すフラグ
    @Published private(set) var canLogout = true
    /// ログイン中のユーザー
    @Published private(set) var user: User?
    /// ローディング状態
    @Published private(set) var loadingState: LoadingState = .idle {
        didSet {
            if case .failed(let error, _) = loadingState {
                switch error {
                case _ as AuthenticationError:
                    presentsAuthenticationErrorAlert = true
                case _ as NetworkError:
                    presentsNetworkErrorAlert = true
                case _ as ServerError:
                    presentsServerErrorAlert = true
                default:
                    presentsSystemErrorAlert = true
                }
            }
        }
    }
    
    func loadUser() async {
        // 処理が二重に実行されるのを防ぐ。
        guard loadingState != .loading else { return }
        
        loadingState = .loading
        
        do {
            // API を叩いて User を取得。
            let user = try await UserService.currentUser()
            loadingState = .loaded
            // 取得した情報を View に反映。
            self.user = user
        } catch {
            logger.info("\(error)")
            let message = errorHandle(error)
            loadingState = .failed(error: error, message: message)
        }
    }
    
    func logOut() async {
        // 処理が二重に実行されるのを防ぐ。
        guard loadingState != .loading, canLogout else { return }
        
        loadingState = .loading
        canLogout = false

        // API を叩いて処理を実行。
        await AuthService.logOut()
        
        loadingState = .loaded
        
        // この View から遷移するのでボタンの押下受け付けは再開しない。
        // 遷移アニメーション中に処理が実行されることを防ぐ。
    }
}
