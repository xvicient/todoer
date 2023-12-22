import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    private let store: Store<Authentication.Reducer>
    
    init(store: Store<Authentication.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    Text("Welcome")
                        .foregroundColor(.buttonPrimary)
                        .padding([.top], 20)
                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                    Image("Logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding([.top], 20)
                        .padding([.bottom], 40)
                    Text("Get things done with Todoo!")
                        .foregroundColor(.buttonPrimary)
                        .padding([.bottom], 20)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .background(.backgroundPrimary)
                VStack {
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
                    .padding([.top, .leading, .trailing], 40)
                    Text("Login using a Google account.")
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 14, design: .rounded))
                    Spacer()
                }
                .background(.backgroundSecondary)
            }
            if store.state.isLoading {
                ProgressView()
            }
        }
    }
}

//#Preview {
//    Authentication.Builder.makeAuthentication(coordinator: Coordinator())
//}
