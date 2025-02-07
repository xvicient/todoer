import Combine
import Foundation
import Data
import Application
import Entities

/// Protocol defining the home screen use case API
protocol HomeUseCaseApi {
    /// Fetches lists and invitations data
    /// - Returns: A publisher that emits home data or an error
    func fetchData() -> AnyPublisher<HomeData, Error>

    /// Updates a user list
    /// - Parameter list: The list to update
    /// - Returns: A result containing the updated list or an error
    func updateList(
        list: UserList
    ) async -> ActionResult<UserList>

    /// Deletes a list
    /// - Parameter documentId: ID of the list to delete
    /// - Returns: A result indicating success or failure
    func deleteList(
        _ documentId: String
    ) async -> ActionResult<EquatableVoid>

    /// Adds a new list
    /// - Parameter name: Name of the new list
    /// - Returns: A result containing the new list or an error
    func addList(
        name: String
    ) async -> ActionResult<UserList>

    /// Sorts lists in the specified order
    /// - Parameter lists: Array of lists in their new order
    /// - Returns: A result indicating success or failure
    func sortLists(
        lists: [UserList]
    ) async -> ActionResult<EquatableVoid>
}

extension Home {
    /// Data structure containing lists and invitations
    struct HomeData: Equatable, Sendable {
        /// Array of user lists
        let lists: [UserList]
        /// Array of pending invitations
        let invitations: [Invitation]
    }
    
    /// Implementation of the home screen use case
    struct UseCase: HomeUseCaseApi {
        /// Possible errors that can occur in the use case
        private enum Errors: Error, LocalizedError {
            /// Error when attempting to create a list with an empty name
            case emptyListName

            var errorDescription: String? {
                switch self {
                case .emptyListName:
                    return "UserList can't be empty."
                }
            }
        }

        /// Repository for managing lists
        private let listsRepository: ListsRepositoryApi
        /// Repository for managing list items
        private let itemsRepository: ItemsRepositoryApi
        /// Repository for managing invitations
        private let invitationsRepository: InvitationsRepositoryApi

        /// Initializes the use case with required dependencies
        /// - Parameters:
        ///   - listsRepository: Repository for list operations
        ///   - itemsRepository: Repository for item operations
        ///   - invitationsRepository: Repository for invitation operations
        init(
            listsRepository: ListsRepositoryApi = ListsRepository(),
            itemsRepository: ItemsRepositoryApi = ItemsRepository(),
            invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()
        ) {
            self.listsRepository = listsRepository
            self.itemsRepository = itemsRepository
            self.invitationsRepository = invitationsRepository
        }

        /// Fetches both lists and invitations data
        /// - Returns: A publisher that emits combined home data or an error
        func fetchData() -> AnyPublisher<HomeData, Error> {
            Publishers.CombineLatest(
                fetchLists(),
                fetchInvitations()
            )
            .map { HomeData(lists: $0, invitations: $1) }
            .eraseToAnyPublisher()
        }

        /// Updates a list and its items' status
        /// - Parameter list: The list to update
        /// - Returns: A result containing the updated list or an error
        func updateList(
            list: UserList
        ) async -> ActionResult<UserList> {
            do {
                let updatedList = try await listsRepository.updateList(list)
                try await itemsRepository.toogleAllItems(
                    listId: list.documentId,
                    done: list.done
                )
                return .success(updatedList)
            }
            catch {
                return .failure(error)
            }
        }

        /// Deletes a list and its associated items
        /// - Parameter documentId: ID of the list to delete
        /// - Returns: A result indicating success or failure
        func deleteList(
            _ documentId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await listsRepository.deleteList(documentId)
                return .success()
            }
            catch {
                return .failure(error)
            }
        }

        /// Creates a new list with the specified name
        /// - Parameter name: Name of the new list
        /// - Returns: A result containing the new list or an error
        func addList(
            name: String
        ) async -> ActionResult<UserList> {
            guard !name.isEmpty else {
                return .failure(Errors.emptyListName)
            }

            do {
                let list = try await listsRepository.addList(with: name)
                return .success(list)
            }
            catch {
                return .failure(error)
            }
        }

        /// Updates the order of lists
        /// - Parameter lists: Array of lists in their new order
        /// - Returns: A result indicating success or failure
        func sortLists(
            lists: [UserList]
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await listsRepository.sortLists(lists: lists)
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
    }
}

extension Home.UseCase {
    /// Fetches and sorts user lists
    /// - Returns: A publisher that emits sorted lists or an error
    fileprivate func fetchLists() -> AnyPublisher<[UserList], Error> {
        listsRepository.fetchLists()
            .map { lists in
                lists.sorted { $0.index < $1.index }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Fetches, sorts, and processes invitations
    /// - Returns: A publisher that emits processed invitations or an error
    fileprivate func fetchInvitations() -> AnyPublisher<[Invitation], Error> {
        invitationsRepository.getInvitations()
            .map { invitations in
                invitations.sorted { $0.index < $1.index }
            }
            .map { invitations in
                invitations.map {
                    var invitation = $0
                    if $0.ownerEmail.isAppleInternalEmail {
                        invitation.ownerEmail = ""
                    }
                    return invitation
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension String {
    /// Checks if the email is an Apple private relay email
    fileprivate var isAppleInternalEmail: Bool {
        contains("privaterelay.appleid.com")
    }
}
