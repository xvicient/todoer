import AuthenticationServices
import CoordinatorMocks
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import Common
import Application
import ThemeAssets
import CoordinatorContract
import Entities
import AuthenticationScreenContract
import Strings

// MARK: - AuthenticationScreen

/// A view that handles user authentication through various providers (Apple, Google)
/// This screen provides a beautiful animated interface for user login
struct AuthenticationScreen: View {
    @ObservedObject private var store: Store<Authentication.Reducer>
    @State private var isTopSpacerVisible = true
    @State private var logoTopPadding = 100.0
    @State private var didFinishAnimation = false
    @State private var sloganScale = 0.0
    @State private var sloganOpacity = 0.0
    @State var caption: String = ""
    private let getThingsDoneText = Strings.Authentication.getThingsDoneText

    /// Initializes the authentication screen with a store
    /// - Parameter store: The store that manages the authentication state
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
        .background(Color.backgroundWhite)
        .disabled(
            store.state.viewState == .loading
        )
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}

// MARK: - ViewBuilders

extension AuthenticationScreen {
    /// The app logo view with animation
    @ViewBuilder
    fileprivate var logoView: some View {
        VStack {
            if isTopSpacerVisible {
                Spacer()
            }
            Image.todoer
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

    /// The animated slogan view that appears after the logo animation
    @ViewBuilder
    fileprivate var sloganView: some View {
        if didFinishAnimation {
            ZStack {
                VStack(alignment: .leading) {
                    Text(caption)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.black)
                }
                .offset(x: 0, y: -90)
                Spacer()
            }
            .padding(30)
            .ignoresSafeArea()
            .onAppear {
                typeWriter(at: getThingsDoneText.startIndex)
            }
        }
    }

    /// The login buttons view containing Apple and Google sign-in options
    @ViewBuilder
    fileprivate var loginButtons: some View {
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
                                .frame(width: 24, height: 24)
                            Text(Strings.Authentication.signInWithGoogleButtonTitle)
                                .foregroundColor(Color.textWhite)
                                .frame(height: 44)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundBlack)
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.top, 400)
            .padding(.horizontal, 50)
            .frame(maxWidth: .infinity)
        }
    }

    /// A loading indicator view shown during authentication processes
    @ViewBuilder
    fileprivate var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }

    /// The app information view showing version and environment details
    @ViewBuilder
    fileprivate var appInfoView: some View {
        if didFinishAnimation {
            VStack {
                Spacer()
                Text(
                    "\(AppInfo.appName) \(AppInfo.appVersion) (\(AppInfo.buildNumber)) - \(AppInfo.environment)"
                )
                .font(.footnote)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Private

extension AuthenticationScreen {
    /// Implements a typewriter effect for the slogan text
    /// - Parameter position: The current position in the text to type
    fileprivate func typeWriter(at position: String.Index) {
        if position == getThingsDoneText.startIndex {
            caption = ""
        }

        if position < getThingsDoneText.endIndex {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                let char = getThingsDoneText[position]
                caption.append(char)
                typeWriter(at: getThingsDoneText.index(after: position))
            }
        }
    }
}

/// Extension to convert ASAuthorization Result to ActionResult
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

/// Preview provider for the AuthenticationScreen
struct AuthenticationScreen_Previews: PreviewProvider {
    struct Dependencies: AuthenticationScreenDependencies {
        let coordinator: CoordinatorApi
    }
    
    static var previews: some View {
        Authentication.Builder.makeAuthentication(
            dependencies: Dependencies(
                coordinator: CoordinatorMock()
            )
        )
    }
}
