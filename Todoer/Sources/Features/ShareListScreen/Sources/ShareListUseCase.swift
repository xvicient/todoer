/// Protocol defining the business logic operations for sharing lists
protocol ShareListUseCaseApi {
    /// Fetches user data for a list of user IDs
    /// - Parameter uids: List of user IDs to fetch data for
    /// - Returns: Publisher emitting share data
    
    /// Shares a list with selected users
    /// - Parameters:
    ///   - list: List to share
    ///   - users: Users to share with
    /// - Returns: Result indicating success or error
}

extension ShareList {
    /// Data structure containing sharing-related information
    struct ShareData: Equatable, Sendable {
        /// List of users that can be shared with
        let users: [User]
        /// The current user's display name
        let selfName: String?
    }
    
    /// Implementation of the ShareListUseCase protocol
    struct UseCase: ShareListUseCaseApi {
        /// Possible errors that can occur during sharing operations
        private enum Errors: Error, LocalizedError {
            /// Indicates that the provided email was not found
            case emailNotFound
            /// Indicates an unexpected error occurred during the operation
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .emailNotFound:
                    return "Email not found."
                case .unexpectedError:
                    return "Unexpected error."
                }
            }
        }

        private let usersRepository: UsersRepositoryApi
        private let invitationsRepository: InvitationsRepositoryApi

        /// Initializes a new ShareListUseCase instance
        /// - Parameters:
        ///   - usersRepository: Repository for user-related operations
        ///   - invitationsRepository: Repository for invitation-related operations
        init(
            usersRepository: UsersRepositoryApi = UsersRepository(),
            invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()
        ) {
            self.usersRepository = usersRepository
            self.invitationsRepository = invitationsRepository
        }

        /// Fetches user data excluding the current user
        /// - Parameter uids: List of user IDs to fetch data for
        /// - Returns: Publisher emitting share data
        func fetchData(
            uids: [String]
        ) async -> ActionResult<ShareData> {
            do {
                let users = try await usersRepository.getNotSelfUsers(uids: uids)
                let displayName = try? await usersRepository.getSelfUser()?.displayName
                return .success(ShareData(users: users, selfName: displayName))
            }
            catch {
                return .failure(error)
            }
        }

        /// Shares a list with selected users
        /// - Parameters:
        ///   - list: List to share
        ///   - users: Users to share with
        /// - Returns: Result indicating success or error
        ///
        /// This function:
        /// 1. Verifies the target email exists
        /// 2. Checks if an invitation already exists
        /// 3. Gets the current user's information
        /// 4. Creates and sends the invitation
        func shareList(
            list: UserList,
            users: [User]
        ) async -> ActionResult<EquatableVoid> {
            do {
                for user in users {
                    guard let invitedUser = try? await usersRepository.getUser(email: user.email) else {
                        return .failure(Errors.emailNotFound)
                    }

                    guard
                        (try? await invitationsRepository.getInvitation(
                            invitedId: invitedUser.uid,
                            listId: list.documentId
                        )) == nil
                    else {
                        return .success()
                    }

                    guard
                        let selfUser = try? await usersRepository.getSelfUser(),
                        let ownerEmail = selfUser.email
                    else {
                        return .failure(Errors.unexpectedError)
                    }

                    try await invitationsRepository.sendInvitation(
                        ownerName: user.displayName,
                        ownerEmail: ownerEmail,
                        listId: list.documentId,
                        listName: list.name,
                        invitedId: invitedUser.uid
                    )
                }

                return .success()
            }
            catch {
                return .failure(error)
            }
        }
    }
}
