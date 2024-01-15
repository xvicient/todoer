import SwiftUI
import _AuthenticationServices_SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @ObservedObject private var store: Store<Authentication.Reducer>
    @State private var isTopSpacerVisible = true
    @State private var logoTopPadding = 100.0
    @State private var isLoginButtonVisible = false
    @State private var sloganScale = 0.0
    @State private var sloganOpacity = 0.0
    @State private var isModalVisible = false
    @State private var loginDetent = PresentationDetent.height(171)
    
    init(store: Store<Authentication.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            VStack {
                if isTopSpacerVisible {
                    Spacer()
                }
                Image(Constants.Image.launchScreen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 50)
                    .padding(.top, logoTopPadding)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.5).delay(1.0)) {
                            isTopSpacerVisible = false
                        } completion: {
                            withAnimation(Animation.easeInOut(duration: 0.25).delay(0.25)) {
                                sloganOpacity = 1.0
                                sloganScale = 1.3
                            } completion: {
                                withAnimation(Animation.easeInOut(duration: 0.25)) {
                                    sloganScale = 1.0
                                    isLoginButtonVisible = true
                                }
                            }
                        }
                    }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            VStack {
                Image(Constants.Image.slogan)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(sloganScale)
                    .opacity(sloganOpacity)
                    .padding(.horizontal, 50)
                    .padding(.top, 250)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            if isLoginButtonVisible {
                VStack {
                    Spacer()
                    Button(action: {
                        isModalVisible = true
                    }) {
                        Text(Constants.Text.login)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 50)
                    Spacer()
                }
                .padding(.top, 400)
                .frame(maxWidth: .infinity)
            }
            if store.state.viewState == .loading {
                ProgressView()
            }
        }
        .background(.main)
        .sheet(isPresented: $isModalVisible, content: {
            LoginButtonsView(onClose: {
                withAnimation {
                    isModalVisible = false
                } completion: {
                    store.send(.didTapSignInButton)
                }
            })
            .presentationDetents(
                [loginDetent],
                selection: $loginDetent
            )
        })
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
        .disabled(
            store.state.viewState == .loading
        )
    }
}

// MARK: - LoginButtonsView

private extension AuthenticationView {
    struct LoginButtonsView: View {
        var onClose: () -> Void
        
        var body: some View {
            VStack(alignment: .center, spacing: 25) {
                GoogleSignInButton(
                    viewModel: GoogleSignInButtonViewModel(
                        scheme: .light,
                        style: .standard,
                        state: .normal
                    )
                ) {
                    onClose()
                }
                .frame(height: 48)
                .padding(.horizontal, 50)
                
                SignInWithAppleButton(
                    onRequest: { _ in
                        
                    },
                    onCompletion: { _ in
                        
                    })
                .frame(height: 44)
                .signInWithAppleButtonStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.black, lineWidth: 1)
                )
                .padding(.horizontal, 50)
            }
        }
    }
}

// MARK: - Constants

private extension AuthenticationView {
    struct Constants {
        struct Text {
            static let login = "Login"
            static let errorTitle = "Error"
            static let unexpectedError = "Unexpected error"
            static let errorOkButton = "Ok"
            
        }
        struct Image {
            static let launchScreen = "LaunchScreen"
            static let slogan = "Slogan"
        }
    }
}

#Preview {
    Authentication.Builder.makeAuthentication(coordinator: Coordinator())
}
