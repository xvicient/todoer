import Combine
import Foundation
import Entities

/// Protocol defining the API for managing user lists
public protocol ListsRepositoryApi {
    /// Retrieves all lists for the current user
    /// - Returns: A publisher that emits an array of user lists or an error
    func fetchLists(
    ) -> AnyPublisher<[UserList], Error>

    /// Creates a new list
    /// - Parameter name: Name of the list
    /// - Returns: The created list
    /// - Throws: Error if creation fails
    func addList(
        with name: String
    ) async throws -> UserList

    /// Deletes a list and all its items
    /// - Parameter documentId: ID of the list to delete
    /// - Throws: Error if deletion fails
    func deleteList(
        _ documentId: String
    ) async throws

    /// Imports a shared list for the current user
    /// - Parameter id: ID of the list to import
    /// - Throws: Error if import fails
    func importList(
        id: String
    ) async throws

    /// Updates an existing list
    /// - Parameter list: Updated list data
    /// - Returns: The updated list
    /// - Throws: Error if update fails
    func updateList(
        _ list: UserList
    ) async throws -> UserList

    /// Updates the order of lists
    /// - Parameter lists: Array of lists with updated indices
    /// - Throws: Error if sorting fails
    func sortLists(
        lists: [UserList]
    ) async throws

    /// Deletes all lists owned by the current user
    /// - Throws: Error if deletion fails
    func deleteSelfUserLists(
    ) async throws
}

/// Implementation of ListsRepositoryApi using Firebase Firestore
public final class ListsRepository: ListsRepositoryApi {

    /// Type alias for search field to improve code readability
    typealias SearchField = ListsDataSource.SearchField

    /// Data source for managing lists in Firestore
    private let listsDataSource: ListsDataSourceApi = ListsDataSource()
    /// Data source for managing users in Firestore
    private let usersDataSource: UsersDataSourceApi = UsersDataSource()
    /// Data source for managing items in Firestore
    private let itemsDataSource: ItemsDataSourceApi = ItemsDataSource()

    /// Creates a new lists repository
    public init() {}

    /// Retrieves all lists for the current user
    /// - Returns: A publisher that emits an array of user lists or an error
    public func fetchLists() -> AnyPublisher<[UserList], Error> {
        listsDataSource.fetchLists(uid: usersDataSource.uid)
            .tryMap { lists in
                lists.map {
                    $0.toDomain
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Creates a new list
    /// - Parameter name: Name of the list
    /// - Returns: The created list
    /// - Throws: Error if creation fails
    public func addList(
        with name: String
    ) async throws -> UserList {
        try await listsDataSource.addList(
            with: name,
            uid: usersDataSource.uid
        ).toDomain
    }

    /// Deletes a list and all its items
    /// - Parameter documentId: ID of the list to delete
    /// - Throws: Error if deletion fails
    public func deleteList(
        _ documentId: String
    ) async throws {
        let itemsDocuments = try await itemsDataSource.documents(listId: documentId)
        try await listsDataSource.deleteListAndAllItems(
            listId: documentId,
            itemsDocuments: itemsDocuments
        )
    }

    /// Imports a shared list for the current user
    /// - Parameter id: ID of the list to import
    /// - Throws: Error if import fails
    public func importList(
        id: String
    ) async throws {
        try await listsDataSource.importList(id: id, uid: usersDataSource.uid)
    }

    /// Updates an existing list
    /// - Parameter list: Updated list data
    /// - Returns: The updated list
    /// - Throws: Error if update fails
    public func updateList(
        _ list: UserList
    ) async throws -> UserList {
        try await listsDataSource.updateList(list.toDTO).toDomain
    }

    /// Updates the order of lists
    /// - Parameter lists: Array of lists with updated indices
    /// - Throws: Error if sorting fails
    public func sortLists(
        lists: [UserList]
    ) async throws {
        try await listsDataSource.sortLists(
            lists: lists.map { $0.toDTO }
        )
    }

    /// Deletes all lists owned by the current user
    /// - Throws: Error if deletion fails
    public func deleteSelfUserLists() async throws {
        try await listsDataSource.deleteLists(
            with: [SearchField(.uid, .arrayContains(usersDataSource.uid))]
        )
    }
}

/// Extension to convert ListDTO to domain model
extension ListDTO {
    /// Converts the DTO to a domain model
    fileprivate var toDomain: UserList {
        UserList(
            id: UUID(),
            documentId: id ?? "",
            name: name,
            done: done,
            uid: uid,
            index: index
        )
    }
}

/// Extension to convert UserList to DTO
extension UserList {
    /// Converts the domain model to a DTO
    fileprivate var toDTO: ListDTO {
        ListDTO(
            id: documentId,
            name: name,
            done: done,
            uid: uid,
            index: index
        )
    }
}
