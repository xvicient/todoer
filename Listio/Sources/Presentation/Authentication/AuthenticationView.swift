import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel:AuthenticationViewModel
    
    var body: some View {
        GoogleSignInButton(
            viewModel: GoogleSignInButtonViewModel(
                scheme: .light,
                style: .standard,
                state: .normal
            )
        ) {
            Task {
                do {
                    try await viewModel.signInGoogle()
                    coordinator.push(.home)
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    AuthenticationView(
        viewModel: AuthenticationViewModel(
            usersRepository: UsersRepository()
        )
    )
}
