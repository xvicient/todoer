import Application
import Entities

@testable import ShareListScreen

/// Mock implementation of ShareListUseCaseApi for testing purposes
class ShareListUseCaseMock: ShareListUseCaseApi {
    /// Result to return for fetchData operations
    var fetchDataResult: ActionResult<ShareData>!
    /// Result to return for shareList operations
    var shareListResult: ActionResult<EquatableVoid>!

    /// Mock error type for testing failure scenarios
    enum UseCaseError: Error {
        case error
    }

    /// Mock implementation of fetchData
    /// - Parameter uids: List of user IDs to fetch data for
    /// - Returns: Publisher emitting configured result
    func fetchData(
        uids: [String]
    ) async -> ActionResult<ShareData> {
        fetchDataResult
    }

    /// Mock implementation of shareList
    /// - Parameters:
    ///   - list: List to share
    ///   - users: Users to share with
    /// - Returns: The configured mock result
    func shareList(
        shareEmail: String,
        ownerName: String,
        list: UserList
    ) async -> ActionResult<EquatableVoid> {
        shareListResult
    }
}
