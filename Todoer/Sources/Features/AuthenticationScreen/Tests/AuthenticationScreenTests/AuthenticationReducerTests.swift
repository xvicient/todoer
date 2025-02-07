/// Unit tests for the Authentication screen functionality
@MainActor
final class AuthenticationReducerTests: XCTestCase {
    /// Dependencies required by the Authentication reducer
    struct Dependencies: AuthenticationScreenDependencies {
        var coordinator: CoordinatorApi
    }

    /// Test store instance with mock dependencies
    private lazy var store: AuthenticationStore<Authentication.Reducer> = {
        TestStore(
            initialState: .init(),
            reducer: Authentication.Reducer(
                dependencies: Dependencies(
                    coordinator: coordinator
                ),
                useCase: useCaseMock
            )
        )
    }()
    /// Mock use case for testing
    private var useCaseMock = AuthenticationUseCaseMock()
    /// Mock coordinator for testing navigation
    private var coordinator = CoordinatorMock()

    /// Tests Apple Sign In (pending implementation)
    /// - Note: See https://github.com/lukejones1/AppleSignIn/tree/master for reference
    func testDidTapAppleSignInButton_Success() async {}

    /// Tests successful Google Sign In
    /// Verifies loading state and navigation after success
    func testDidTapGoogleSignInButton_Success() async {
        givenASuccessfullSingIn()

        await store.send(.didTapGoogleSignInButton) {
            $0.viewState == .loading
        }

        await store.receive(.signInResult(useCaseMock.result)) {
            $0.viewState == .idle
        }

        XCTAssert(coordinator.isLoggInCalled)
    }

    /// Tests failed Google Sign In
    /// Verifies error state and error dismissal
    func testDidTapGoogleSignInButton_Failure() async {
        givenAFailureSingIn()

        await store.send(.didTapGoogleSignInButton) {
            $0.viewState == .loading
        }

        await store.receive(.signInResult(useCaseMock.result)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
        }

        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }
}

/// Test helper methods for configuring mock behavior
extension AuthenticationReducerTests {
    /// Configures mock for successful sign in
    fileprivate func givenASuccessfullSingIn() {
        useCaseMock.result = .success()
    }

    /// Configures mock for failed sign in
    fileprivate func givenAFailureSingIn() {
        useCaseMock.result = .failure(UseCaseError.error)
    }
}
