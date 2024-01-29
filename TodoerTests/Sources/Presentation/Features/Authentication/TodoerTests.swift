import XCTest
@testable import Todoer

final class AuthenticationReducerTests: XCTestCase {
    struct Dependencies: AuthenticationDependencies {
        var useCase: AuthenticationUseCaseApi
    }
    
    var store: Store<Authentication.Reducer>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        setupStore()
    }
    
    @MainActor
    private func setupStore() {
        store = Store(
            initialState: .init(),
            reducer: Authentication.Reducer(
                coordinator: Coordinator(),
                dependencies: Dependencies(
                    useCase: Authentication.UseCase()
                )
            )
        )
    }
    
    func testDidTapGoogleSignInButton() async {
        await store.send(.didTapGoogleSignInButton)
        
        // TODO: - Test Reducer.Action.signInResult is called and the data
    }
}
