import xRedux
import Entities

@testable import ShareListScreen

class ShareListUseCaseMock: ShareListUseCaseApi {

	var fetchDataResult: ActionResult<ShareData>!
	var shareListResult: ActionResult<EquatableVoid>!

	enum UseCaseError: Error {
		case error
	}

	func fetchData(
		uids: [String]
	) async -> ActionResult<ShareData> {
        fetchDataResult
	}

	func shareList(
        shareEmail: String,
        ownerName: String,
        list: UserList
	) async -> ActionResult<EquatableVoid> {
		shareListResult
	}

}
