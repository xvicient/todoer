import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @EnvironmentObject private var store: Authentication.Store
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .light,
                    style: .standard,
                    state: .normal
                )
            ) {
                store.send(.didTapSignInButton)
            }
            
            if store.state.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    Authentication.Builder.makeAuthentication()
}
