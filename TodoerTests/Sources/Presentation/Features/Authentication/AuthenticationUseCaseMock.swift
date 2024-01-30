@testable import Todoer

class AuthenticationUseCaseMock: AuthenticationUseCaseApi {
    var result: Result<Void, Error>!
    
    enum UseCaseError: Error {
        case error
    }
    
    func singIn(
        provider: Authentication.Provider
    ) async -> (Result<Void, Error>) {
        result
    }
}
