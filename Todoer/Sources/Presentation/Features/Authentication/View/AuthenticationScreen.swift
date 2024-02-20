import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

// MARK: - AuthenticationScreen

struct AuthenticationScreen: View {
    @ObservedObject private var store: Store<Authentication.Reducer>
    @State private var isTopSpacerVisible = true
    @State private var logoTopPadding = 100.0
    @State private var didFinishAnimation = false
    @State private var sloganScale = 0.0
    @State private var sloganOpacity = 0.0
    @State var caption: String = ""
    
    init(store: Store<Authentication.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            logoView
            sloganView
            loginButtons
            loadingView
            appInfoView
        }
        .background(.backgroundWhite)
        .alert(isPresented: alertBinding) {
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: alertErrorMessage,
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

// MARK: - ViewBuilders

private extension AuthenticationScreen {
    @ViewBuilder
    var logoView: some View {
        VStack {
            if isTopSpacerVisible {
                Spacer()
            }
            Image.launchScreen
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 35)
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
                                didFinishAnimation = true
                            }
                        }
                    }
                }
            Spacer()
        }
        .frame(maxWidth: .infinity)

    }
    
    @ViewBuilder
    var sloganView: some View {
        if didFinishAnimation {
            ZStack {
                VStack(alignment: .leading) {
                    Text(caption)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                }
                .offset(x:0, y: -90)
                Spacer()
            }
            .padding(30)
            .ignoresSafeArea()
            .onAppear{
                typeWriter(at: Constants.Text.getThingsDone.startIndex)
            }
        }
    }
    
    @ViewBuilder
    var loginButtons: some View {
        if didFinishAnimation {
            VStack(spacing: 16) {
                Spacer()
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    store.send(.didAppleSignIn($0.actionResult))
                }
                .frame(height: 44)
                .signInWithAppleButtonStyle(.black)
                
                Button(action: {
                    store.send(.didTapGoogleSignInButton)
                }) {
                    HStack {
                        HStack {
                            Image.googleLogo
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text(Constants.Text.signInWithGoogle)
                                .foregroundColor(.textWhite)
                                .frame(height: 44)
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity)
                    .background(.backgroundBlack)
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.top, 400)
            .padding(.horizontal, 50)
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var appInfoView: some View {
        if didFinishAnimation {
            VStack {
                Spacer()
                Text("\(AppInfo.appName) \(AppInfo.appVersion) (\(AppInfo.buildNumber)) - \(AppInfo.environment)")
                    .font(.footnote)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    var alertErrorMessage: Text? {
        if case let .error(error) = store.state.viewState {
            Text(error)
        }
    }
}

// MARK: - Private

private extension AuthenticationScreen {
    func typeWriter(at position: String.Index) {
        if position == Constants.Text.getThingsDone.startIndex {
            caption = ""
        }
        
        if position < Constants.Text.getThingsDone.endIndex {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                let char = Constants.Text.getThingsDone[position]
                caption.append(char)
                typeWriter(at: Constants.Text.getThingsDone.index(after: position))
            }
        }
    }
    
    var alertBinding: Binding<Bool> {
        Binding(
            get: {
                if case .error = store.state.viewState { return true } else { return false }
            },
            set: { _ in }
        )
    }
}

// MARK: - Constants

internal extension AuthenticationScreen {
    struct Constants {
        struct Text {
            static let login = "Login"
            static let signInWithGoogle = "Sign in with Google"
            static let errorTitle = "Error"
            static let errorOkButton = "Ok"
            static let getThingsDone = "Get things done!"
        }
    }
}

extension Result where Success == ASAuthorization {
    var actionResult: ActionResult<ASAuthorization> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}

#Preview {
    Authentication.Builder.makeAuthentication(coordinator: Coordinator())
}
