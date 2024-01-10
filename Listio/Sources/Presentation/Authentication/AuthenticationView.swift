import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @ObservedObject private var store: Store<Authentication.Reducer>
    
    init(store: Store<Authentication.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack {
                    Text(Constants.Text.welcomeTitle)
                        .foregroundColor(.buttonPrimary)
                        .padding([.top], 20)
                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                    Image(Constants.Image.logo)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding([.top], 20)
                        .padding([.bottom], 40)
                    Text(Constants.Text.welcomeSubtitle)
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
                        store.send(.didTapSignInButton)
                    }
                    .padding([.top, .leading, .trailing], 40)
                    Text(Constants.Text.loginHint)
                        .foregroundColor(.buttonPrimary)
                        .font(.system(size: 14, design: .rounded))
                    Spacer()
                }
                .background(.backgroundSecondary)
            }
            if store.state.viewState == .loading {
                ProgressView()
            }
        }
        .alert(isPresented: Binding(
            get: { store.state.viewState == .unexpectedError },
            set: { _ in }
        )) {
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: Text(Constants.Text.unexpectedError),
                dismissButton: .default(Text(Constants.Text.errorOkButton)) {
                    store.send(.didTapDismissError)
                }
            )
        }
    }
}

// MARK: - Constants

private extension AuthenticationView {
    struct Constants {
        struct Text {
            static let welcomeTitle = "Welcome"
            static let welcomeSubtitle = "Get things done with Todoo!"
            static let loginHint = "Login using a Google account."
            static let errorTitle = "Error"
            static let unexpectedError = "Unexpected error"
            static let errorOkButton = "Ok"
            
        }
        struct Image {
            static let logo = "Logo"
        }
    }
}

#Preview {
    Authentication.Builder.makeAuthentication(coordinator: Coordinator())
}
