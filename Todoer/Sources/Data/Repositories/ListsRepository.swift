import Combine
import Foundation

protocol ListsRepositoryApi {
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

final class ListsRepository: ListsRepositoryApi {

	typealias SearchField = ListsDataSource.SearchField

	let listsDataSource: ListsDataSourceApi
	let usersDataSource: UsersDataSourceApi
	let itemsDataSource: ItemsDataSourceApi

	init(
		listsDataSource: ListsDataSourceApi = ListsDataSource(),
		usersDataSource: UsersDataSourceApi = UsersDataSource(),
		itemsDataSource: ItemsDataSourceApi = ItemsDataSource()
	) {
		self.listsDataSource = listsDataSource
		self.usersDataSource = usersDataSource
		self.itemsDataSource = itemsDataSource
	}

	func fetchLists() -> AnyPublisher<[List], Error> {
		listsDataSource.fetchLists(uid: usersDataSource.uid)
			.tryMap { lists in
				lists.map {
					$0.toDomain
				}
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func addList(
		with name: String
	) async throws -> List {
		try await listsDataSource.addList(
			with: name,
			uid: usersDataSource.uid
		).toDomain
	}

	func deleteList(
		_ documentId: String
	) async throws {
		try await listsDataSource.deleteList(documentId)
	}

	func importList(
		id: String
	) async throws {
		try await listsDataSource.importList(id: id, uid: usersDataSource.uid)
	}

	func updateList(
		_ list: List
	) async throws -> List {
		try await listsDataSource.updateList(list.toDTO).toDomain
	}

	func sortLists(
		lists: [List]
	) async throws {
		try await listsDataSource.sortLists(
			lists: lists.map { $0.toDTO }
		)
	}

	func deleteSelfUserLists() async throws {
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
