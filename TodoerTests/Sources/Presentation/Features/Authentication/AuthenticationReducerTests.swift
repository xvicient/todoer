import XCTest
@testable import Todoer

@MainActor
final class AuthenticationReducerTests: XCTestCase {
    struct Dependencies: AuthenticationDependencies {
        var useCase: AuthenticationUseCaseApi
    }
    
    var store: TestStore<Authentication.Reducer>!
    
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
                    useCase: UseCaseMock()
                )
            )
        )
    }
    
    func testDidTapGoogleSignInButton() async {
        store.send(.didTapGoogleSignInButton)

        XCTAssertEqual(store.state.viewState, .loading)
        
        await store.receive(.signInResult(.success(()))) {
            $0.viewState == .idle
        }
    }
    
    func test1() {
        XCTAssert(true)
    }
}

struct UseCaseMock: AuthenticationUseCaseApi {
    enum UseCaseError: Error {
        case error
    }
    func singIn(provider: Authentication.Provider) async -> (Result<Void, Error>) {
        .success(())
//        .failure(UseCaseError.error)
    }
    
    
}
