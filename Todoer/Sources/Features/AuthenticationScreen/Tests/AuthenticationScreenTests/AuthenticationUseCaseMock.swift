import xRedux

@testable import AuthenticationScreen

class AuthenticationUseCaseMock: AuthenticationUseCaseApi {
    var result: VoidResult!

    enum UseCaseError: Error {
        case error
    }

    func singIn(
        provider: Authentication.Provider
    ) async -> VoidResult {
        result
    }
}
