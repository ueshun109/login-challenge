import Combine
import UIKit
import Entities
import APIServices
import Logging
import SwiftUI

@MainActor
final class LoginViewController: UIViewController {
    @IBOutlet private var idField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    
    @ObservedObject private var viewModel = LoginViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$enableLoginButton
            .assign(to: \UIButton.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        viewModel.$canInput
            .assign(to: \UITextField.isEnabled, on: idField)
            .store(in: &cancellables)
        
        viewModel.$canInput
            .assign(to: \UITextField.isEnabled, on: passwordField)
            .store(in: &cancellables)
        
        viewModel.$loadingState
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.showLoadingIndicator()
                case .loaded:
                    self.hideLoadingIndicator()
                    self.pushToHomeView()
                case let .failed(_, message):
                    self.hideLoadingIndicator()
                    self.showAlertDialog(message)
                default:
                    return
                }
            }
            .store(in: &cancellables)
    }
    
    // ログインボタンが押されたときにログイン処理を実行。
    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        Task {
            await viewModel.login()
        }
    }
    
    // ID およびパスワードのテキストが変更されたときに View の状態を更新。
    @IBAction private func inputFieldValueChanged(sender: UITextField) {
        if sender === idField {
            viewModel.id = sender.text ?? ""
        }

        if sender === passwordField {
            viewModel.password = sender.text ?? ""
        }
    }
}

private extension LoginViewController {
    /// ローディングインジケーターを非表示にする
    func hideLoadingIndicator() {
        Task {
            await dismiss(animated: true)
        }
    }
    
    /// ホーム画面に遷移する
    func pushToHomeView() {
        Task {
            let destination = UIHostingController(rootView: HomeView(dismiss: { [weak self] in
                await self?.dismiss(animated: true)
            }))
            destination.modalPresentationStyle = .fullScreen
            destination.modalTransitionStyle = .flipHorizontal
            await present(destination, animated: true)
        }
    }
    
    /// アラートダイアログを表示する
    func showAlertDialog(_ error: ErrorMessage) {
        Task {
            let alertController: UIAlertController = .init(
                title: error.title,
                message: error.message,
                preferredStyle: .alert
            )
            alertController.addAction(.init(title: "閉じる", style: .default, handler: nil))
            await present(alertController, animated: true)
        }
    }
    
    /// ローディングインジケーターを表示する
    func showLoadingIndicator() {
        Task {
            let activityIndicatorViewController: ActivityIndicatorViewController = .init()
            activityIndicatorViewController.modalPresentationStyle = .overFullScreen
            activityIndicatorViewController.modalTransitionStyle = .crossDissolve
            await present(activityIndicatorViewController, animated: true)
        }
    }
}
