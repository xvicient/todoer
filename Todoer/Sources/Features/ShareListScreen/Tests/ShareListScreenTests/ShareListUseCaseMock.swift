import Application
import Entities

@testable import ShareListScreen

class ShareListUseCaseMock: ShareListUseCaseApi {

	var fetchUsersResult: ActionResult<[User]>!
	var shareListResult: ActionResult<EquatableVoid>!

	enum UseCaseError: Error {
		case error
	}

	func fetchUsers(
		uids: [String]
	) async -> ActionResult<[User]> {
		fetchUsersResult
	}

	func shareList(
		shareEmail: String,
		list: UserList
	) async -> ActionResult<EquatableVoid> {
		shareListResult
	}

}
