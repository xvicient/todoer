import Combine
import Foundation

public protocol ListsRepositoryApi {
	func fetchLists() -> AnyPublisher<[UserList], Error>

	func addList(
		with name: String
	) async throws -> UserList

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

	func deleteSelfUserLists() async throws
}

public final class ListsRepository: ListsRepositoryApi {

	typealias SearchField = ListsDataSource.SearchField

	let listsDataSource: ListsDataSourceApi = ListsDataSource()
	let usersDataSource: UsersDataSourceApi = UsersDataSource()
	let itemsDataSource: ItemsDataSourceApi = ItemsDataSource()

    public init() {}

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

    public func addList(
		with name: String
	) async throws -> UserList {
		try await listsDataSource.addList(
			with: name,
			uid: usersDataSource.uid
		).toDomain
	}

    public func deleteList(
		_ documentId: String
	) async throws {
		try await listsDataSource.deleteList(documentId)
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
