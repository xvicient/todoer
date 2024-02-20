@testable import Todoer

class AuthenticationUseCaseMock: AuthenticationUseCaseApi {
	var result: ActionResult<EquatableVoid>!

	enum UseCaseError: Error {
		case error
	}

	func singIn(
		provider: Authentication.Provider
	) async -> ActionResult<EquatableVoid> {
		result
	}
}
