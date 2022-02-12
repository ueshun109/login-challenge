import Entities

struct HomeErrorHandling {
    func callAsFunction(_ error: Error) -> ErrorMessage {
        switch error {
        case _ as AuthenticationError:
            return .init(
                title: "認証エラー",
                message: "再度ログインして下さい。"
            )
        case _ as NetworkError:
            return .init(
                title: "ネットワークエラー",
                message: "通信に失敗しました。ネットワークの状態を確認して下さい。"
            )
        case _ as ServerError:
            return .init(
                title: "サーバーエラー",
                message: "しばらくしてからもう一度お試し下さい。"
            )
        default:
            return .init(
                title: "システムエラー",
                message: "エラーが発生しました。"
            )
        }
    }
}
