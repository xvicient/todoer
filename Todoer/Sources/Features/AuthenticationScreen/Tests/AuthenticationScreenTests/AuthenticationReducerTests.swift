import AuthenticationScreenContract
import CoordinatorContract
import CoordinatorMocks
import Entities
import XCTest
import xRedux
import xReduxTest

@testable import AuthenticationScreen

@MainActor
final class AuthenticationReducerTests: XCTestCase {
    private typealias AuthenticationStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = AuthenticationUseCaseMock.UseCaseError

    struct Dependencies: AuthenticationScreenDependencies {
        var coordinator: CoordinatorApi
    }

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
    private var useCaseMock = AuthenticationUseCaseMock()
    private var coordinator = CoordinatorMock()

    /// https://github.com/lukejones1/AppleSignIn/tree/master
    func testDidTapAppleSignInButton_Success() async {}

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

extension AuthenticationReducerTests {
    fileprivate func givenASuccessfullSingIn() {
        useCaseMock.result = .success()
    }

    fileprivate func givenAFailureSingIn() {
        useCaseMock.result = .failure(UseCaseError.error)
    }
}
