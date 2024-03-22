import Combine
import Domain
import Foundation

public protocol ListsRepositoryApi {
	func fetchLists() -> AnyPublisher<[List], Error>

	func addList(
		with name: String
	) async throws -> List

	func deleteList(
		_ documentId: String
	) async throws

	func importList(
		id: String
	) async throws

	func updateList(
		_ list: List
	) async throws -> List

	func sortLists(
		lists: [List]
	) async throws

	func deleteSelfUserLists() async throws
}

public final class ListsRepository: ListsRepositoryApi {

	typealias SearchField = ListsDataSource.SearchField

	let listsDataSource: ListsDataSourceApi
	let usersDataSource: UsersDataSourceApi
	let itemsDataSource: ItemsDataSourceApi

	public init(
		listsDataSource: ListsDataSourceApi = ListsDataSource(),
		usersDataSource: UsersDataSourceApi = UsersDataSource(),
		itemsDataSource: ItemsDataSourceApi = ItemsDataSource()
	) {
		self.listsDataSource = listsDataSource
		self.usersDataSource = usersDataSource
		self.itemsDataSource = itemsDataSource
	}

	public func fetchLists() -> AnyPublisher<[List], Error> {
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
	) async throws -> List {
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
		_ list: List
	) async throws -> List {
		try await listsDataSource.updateList(list.toDTO).toDomain
	}

	public func sortLists(
		lists: [List]
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
	fileprivate var toDomain: List {
		List(
			documentId: id ?? "",
			name: name,
			done: done,
			uid: uid,
			index: index
		)
	}
}

extension List {
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
