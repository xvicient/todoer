import Combine
import Foundation
import Entities

public protocol ListsRepositoryApi {
    func setSharedList(_ name: String)
    
	func fetchLists(
    ) -> AnyPublisher<[UserList], Error>

	func addList(
		with name: String
	) async throws -> UserList
    
    func addSharedLists(
    ) async throws -> [UserList]

	func deleteList(
		_ documentId: String
	) async throws

	func importList(
		id: String
	) async throws

	func updateList(
		_ list: UserList
	) async throws -> UserList

	func sortLists(
		lists: [UserList]
	) async throws

	func deleteSelfUserLists(
    ) async throws
}

public final class ListsRepository: ListsRepositoryApi {
    
    typealias SearchField = ListsDataSource.SearchField
    
    private let listsDataSource: ListsDataSourceApi = ListsDataSource()
    private let usersDataSource: UsersDataSourceApi = UsersDataSource()
    private let itemsDataSource: ItemsDataSourceApi = ItemsDataSource()
    private let sharedListsDataSource: SharedListsDataSourceApi = SharedListsDataSource()
    
    public init() {}
    
    public func setSharedList(_ name: String) {
        sharedListsDataSource.sharedLists.append(name)
    }
    
    public func fetchLists() -> AnyPublisher<[UserList], Error> {
        listsDataSource.fetchLists(uid: usersDataSource.uid)
            .tryMap { $0.map(\.toDomain) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func addList(
        with name: String
    ) async throws -> UserList {
        try await listsDataSource.addList(
            with: name,
            uid: usersDataSource.uid
        ).toDomain
    }
    
    public func addSharedLists(
    ) async throws -> [UserList] {
        let result = try await listsDataSource.addLists(
            names: sharedListsDataSource.sharedLists,
            uid: usersDataSource.uid
        ).map(\.toDomain)
        sharedListsDataSource.sharedLists.removeAll()
        return result
    }

    public func deleteList(
		_ documentId: String
	) async throws {
        let itemsDocuments = try await itemsDataSource.documents(listId: documentId)
        try await listsDataSource.deleteListAndAllItems(
            listId: documentId,
            itemsDocuments: itemsDocuments
        )
	}

    public func importList(
		id: String
	) async throws {
		try await listsDataSource.importList(id: id, uid: usersDataSource.uid)
	}

    public func updateList(
		_ list: UserList
	) async throws -> UserList {
		try await listsDataSource.updateList(list.toDTO).toDomain
	}

    public func sortLists(
		lists: [UserList]
	) async throws {
		try await listsDataSource.sortLists(
			lists: lists.map { $0.toDTO }
		)
	}

    public func deleteSelfUserLists() async throws {
		try await listsDataSource.deleteLists(
			with: [SearchField(.uid, .arrayContains(usersDataSource.uid))]
		)
	}
}

extension ListDTO {
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

extension UserList {
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
