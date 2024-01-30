import XCTest
@testable import Todoer

@MainActor
final class AuthenticationReducerTests: XCTestCase {
    struct Dependencies: AuthenticationDependencies {
        var useCase: AuthenticationUseCaseApi
    }
    
    private var store: TestStore<Authentication.Reducer>!
    private var useCaseMock = AuthenticationUseCaseMock()
    private var useCaseError = AuthenticationUseCaseMock.UseCaseError.error
    
    override func setUp() {
        super.setUp()
        setupStore()
    }
    
    private func setupStore() {
        store = TestStore(
            initialState: .init(),
            reducer: Authentication.Reducer(
                coordinator: Coordinator(),
                dependencies: Dependencies(
                    useCase: useCaseMock
                )
            )
        )
    }
    
    func testDidTapGoogleSignInButton_Success() async {
        givenASuccessfullSingIn()
        
        await store.send(.didTapGoogleSignInButton) {
            $0.viewState == .loading
        }
        
        await store.receive(.signInResult(useCaseMock.result)) {
            $0.viewState == .idle
        }
    }
    
    func testDidTapGoogleSignInButton_Failure() async {
        givenAFailureSingIn()
        
        await store.send(.didTapGoogleSignInButton) {
            $0.viewState == .loading
        }
        
        await store.receive(.signInResult(useCaseMock.result)) {
            $0.viewState == .error(useCaseError.localizedDescription)
        }
    }
}

private extension AuthenticationReducerTests {
    func givenASuccessfullSingIn() {
        useCaseMock.result = .success(())
    }
    
    func givenAFailureSingIn() {
        useCaseMock.result = .failure(useCaseError)
    }
}
