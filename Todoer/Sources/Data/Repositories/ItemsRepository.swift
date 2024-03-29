import Combine
import Foundation

protocol ItemsRepositoryApi {
	func fetchItems(
		listId: String
	) -> AnyPublisher<[Item], Error>

	func addItem(
		with name: String,
		listId: String
	) async throws -> Item

	func deleteItem(
		itemId: String,
		listId: String
	) async throws

	func updateItem(
		item: Item,
		listId: String
	) async throws -> Item

	func toogleAllItems(
		listId: String?,
		done: Bool
	) async throws

	func sortItems(
		items: [Item],
		listId: String
	) async throws
}

final class ItemsRepository: ItemsRepositoryApi {
	private let itemsDataSource: ItemsDataSourceApi

	init(producstDataSource: ItemsDataSourceApi = ItemsDataSource()) {
		self.itemsDataSource = producstDataSource
	}

	func fetchItems(
		listId: String
	) -> AnyPublisher<[Item], Error> {
		itemsDataSource.fetchItems(listId: listId)
			.tryMap { items in
				items.map {
					$0.toDomain
				}
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func addItem(
		with name: String,
		listId: String
	) async throws -> Item {
		try await itemsDataSource.addItem(
			with: name,
			listId: listId
		).toDomain
	}

	func deleteItem(
		itemId: String,
		listId: String
	) async throws {
		try await itemsDataSource.deleteItem(
			itemId: itemId,
			listId: listId
		)
	}

	func updateItem(
		item: Item,
		listId: String
	) async throws -> Item {
		try await itemsDataSource.updateItem(
			item: item.toDTO,
			listId: listId
		).toDomain
	}

	func toogleAllItems(
		listId: String?,
		done: Bool
	) async throws {
		try await itemsDataSource.toogleAllItems(
			listId: listId,
			done: done
		)
	}

	func sortItems(
		items: [Item],
		listId: String
	) async throws {
		try await itemsDataSource.sortItems(
			items: items.map { $0.toDTO },
			listId: listId
		)
	}
}

extension ItemDTO {
	fileprivate var toDomain: Item {
		Item(
			documentId: id ?? "",
			name: name,
			done: done,
			index: index
		)
	}
}

extension Item {
	fileprivate var toDTO: ItemDTO {
		ItemDTO(
			id: documentId,
			name: name,
			done: done,
			index: index
		)
	}
}
