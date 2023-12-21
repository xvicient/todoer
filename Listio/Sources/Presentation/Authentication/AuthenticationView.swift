import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @EnvironmentObject private var store: Store<Authentication.Reducer>
    @EnvironmentObject private var coordinator: Coordinator
    
    init() {
        setupNavigationBar()
    }
    
    var body: some View {
        ZStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("Get things done with Todoo")
                Spacer()
                GoogleSignInButton(
                    viewModel: GoogleSignInButtonViewModel(
                        scheme: .light,
                        style: .standard,
                        state: .normal
                    )
                ) {
                    Task {
                        await store.send(.didTapSignInButton)
                    }
                }
                Spacer()
            }
            if store.state.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Todoo")
    }
    
    func setupNavigationBar() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [
                .foregroundColor: UIColor(.buttonPrimary)
            ]
    }
}

#Preview {
    Authentication.Builder.makeAuthentication(coordinator: Coordinator())
}
