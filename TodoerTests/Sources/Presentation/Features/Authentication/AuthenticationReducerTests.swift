import XCTest
@testable import Todoer

@MainActor
final class AuthenticationReducerTests: XCTestCase {
    private typealias AuthenticationStore<R: Reducer> = TestStore<R.State, R.Action>
    
    struct Dependencies: AuthenticationDependencies {
        var useCase: AuthenticationUseCaseApi
    }
    
    private var store: AuthenticationStore<Authentication.Reducer>!
    private var useCaseMock = AuthenticationUseCaseMock()
    private var useCaseError = AuthenticationUseCaseMock.UseCaseError.error
    private var coordinator = TestCoordinator()
    
    override func setUp() {
        super.setUp()
        setupStore()
    }
    
    private func setupStore() {
        store = TestStore(
            initialState: .init(),
            reducer: Authentication.Reducer(
                coordinator: coordinator,
                dependencies: Dependencies(
                    useCase: useCaseMock
                )
            )
        )
    }
    
    /// https://github.com/lukejones1/AppleSignIn/tree/master
    func testDidTapAppleSignInButton_Success() async { }
    
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
            $0.viewState == .error(useCaseError.localizedDescription)
        }
        
        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }
}

private extension AuthenticationReducerTests {
    func givenASuccessfullSingIn() {
        useCaseMock.result = .success()
    }
    
    func givenAFailureSingIn() {
        useCaseMock.result = .failure(useCaseError)
    }
}
