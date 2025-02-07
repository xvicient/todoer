import AppMenuContract
import Combine
import Data
import xRedux

protocol MenuUseCaseApi {
    /// Retrieves the URL of the user's profile photo
    /// - Returns: A result containing either the photo URL string or an error
    func getPhotoUrl() async -> ActionResult<String>

    /// Signs out the current user
    /// - Returns: A result indicating success or failure of the sign-out operation
    func signOut() -> ActionResult<EquatableVoid>

    /// Deletes the current user's account and associated data
    /// - Returns: A result indicating success or failure of the account deletion
    func deleteAccount() async -> ActionResult<EquatableVoid>
}

extension AppMenu {

    struct UseCase: MenuUseCaseApi {

        /// Repository for managing lists
        private let listsRepository: ListsRepositoryApi
        /// Repository for managing users
        private let usersRepository: UsersRepositoryApi
        /// Service for handling authentication
        private let authenticationService: AuthenticationService

        /// Initializes the use case with required dependencies
        /// - Parameters:
        ///   - listsRepository: Repository for list-related operations
        ///   - usersRepository: Repository for user-related operations
        ///   - authenticationService: Service for authentication operations
        init(
            listsRepository: ListsRepositoryApi = ListsRepository(),
            usersRepository: UsersRepositoryApi = UsersRepository(),
            authenticationService: AuthenticationService = AuthenticationService()
        ) {
            self.listsRepository = listsRepository
            self.usersRepository = usersRepository
            self.authenticationService = authenticationService
        }

        /// Retrieves the URL of the user's profile photo
        /// - Returns: A result containing either the photo URL string or an error
        func getPhotoUrl() async -> ActionResult<String> {
            do {
                let photoUrl = try await usersRepository.getSelfUser()?.photoUrl
                return .success(photoUrl ?? "")
            }
            catch {
                return .failure(error)
            }
        }

        /// Signs out the current user
        /// - Returns: A result indicating success or failure of the sign-out operation
        func signOut() -> ActionResult<EquatableVoid> {
            do {
                try authenticationService.signOut()
                usersRepository.setUid("")
                return .success()
            }
            catch {
                return .failure(error)
            }
        }

        /// Deletes the current user's account and associated data
        /// - Returns: A result indicating success or failure of the account deletion
        func deleteAccount() async -> ActionResult<EquatableVoid> {
            do {
                try await usersRepository.deleteUser()
                try await listsRepository.deleteSelfUserLists()
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
    }
}
