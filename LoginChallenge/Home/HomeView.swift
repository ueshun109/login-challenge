import SwiftUI
import Entities
import APIServices
import Logging

@MainActor
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    let dismiss: () async -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(Color(UIColor.systemGray4))
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 0) {
                        Text(viewModel.user?.name ?? "User Name")
                            .font(.title3)
                            .redacted(reason: viewModel.user?.name == nil ? .placeholder : [])
                        Text((viewModel.user?.id.rawValue).map { id in "@\(id)" } ?? "@ididid")
                            .font(.body)
                            .foregroundColor(Color(UIColor.systemGray))
                            .redacted(reason: viewModel.user?.id == nil ? .placeholder : [])
                    }
                    
                    let introduction = viewModel.user?.introduction ?? "Introduction. Introduction. Introduction. Introduction. Introduction. Introduction."
                    if let attributedIntroduction = try? AttributedString(markdown: introduction) {
                        Text(attributedIntroduction)
                            .font(.body)
                            .redacted(reason: viewModel.user?.introduction == nil ? .placeholder : [])
                    } else {
                        Text(introduction)
                            .font(.body)
                            .redacted(reason: viewModel.user?.introduction == nil ? .placeholder : [])
                    }
                    
                    // リロードボタン
                    Button {
                        Task {
                            await viewModel.loadUser()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.loadingState == .loading)
                }
                .padding()
                
                Spacer()
                
                // ログアウトボタン
                Button("Logout") {
                    Task {
                        await viewModel.logOut()
                        // LoginViewController に遷移。
                        await dismiss()
                    }
                }
                .disabled(!viewModel.canLogout)
                .padding(.bottom, 30)
            }
        }
        .alert(
            viewModel.error?.title ?? "",
            isPresented: $viewModel.presentsAuthenticationErrorAlert,
            actions: {
                Button("OK") {
                    Task {
                        // LoginViewController に遷移。
                        await dismiss()
                    }
                }
            },
            message: { Text(viewModel.error?.message ?? "") }
        )
        .alert(
            viewModel.error?.title ?? "",
            isPresented: $viewModel.presentsNetworkErrorAlert,
            actions: { Text("閉じる") },
            message: { Text(viewModel.error?.message ?? "") }
        )
        .alert(
            viewModel.error?.title ?? "",
            isPresented: $viewModel.presentsServerErrorAlert,
            actions: { Text("閉じる") },
            message: { Text(viewModel.error?.message ?? "") }
        )
        .alert(
            viewModel.error?.title ?? "",
            isPresented: $viewModel.presentsSystemErrorAlert,
            actions: { Text("閉じる") },
            message: { Text(viewModel.error?.message ?? "") }
        )
        .activityIndicatorCover(isPresented: viewModel.loadingState == .loading)
        .task {
            await viewModel.loadUser()
        }
    }
}
