import Combine
import Foundation
import Data
import Application

protocol ListItemsUseCaseApi {
	func fetchItems(
		listId: String
	) -> AnyPublisher<[Item], Error>

	func addItem(
		with name: String,
		list: UserList
	) async -> ActionResult<Item>

	func deleteItem(
		itemId: String,
		listId: String
	) async -> ActionResult<EquatableVoid>

	func updateItemName(
		item: Item,
		listId: String
	) async -> ActionResult<Item>

	func updateItemDone(
		item: Item,
		list: UserList
	) async -> ActionResult<Item>

	func sortItems(
		items: [Item],
		listId: String
	) async -> ActionResult<EquatableVoid>
}

extension ListItems {
	struct UseCase: ListItemsUseCaseApi {
		private enum Errors: Error, LocalizedError {
			case emptyItemName

			var errorDescription: String? {
				switch self {
				case .emptyItemName:
					return "Item can't be empty."
				}
			}
		}

		private let itemsRepository: ItemsRepositoryApi
		private let listsRepository: ListsRepositoryApi

		init(
			itemsRepository: ItemsRepositoryApi = ItemsRepository(),
			listsRepository: ListsRepositoryApi = ListsRepository()
		) {
			self.itemsRepository = itemsRepository
			self.listsRepository = listsRepository
		}

		func fetchItems(
			listId: String
		) -> AnyPublisher<[Item], Error> {
			itemsRepository.fetchItems(listId: listId)
				.tryMap { items in
					items.sorted { $0.index < $1.index }
				}
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		}

		func addItem(
			with name: String,
			list: UserList
		) async -> ActionResult<Item> {
			guard !name.isEmpty else {
				return .failure(Errors.emptyItemName)
			}

			do {
				let item = try await itemsRepository.addItem(
					with: name,
					listId: list.documentId
				)

				_ = try await listsRepository.updateList(list)

				return .success(item)
			}
			catch {
				return .failure(error)
			}
		}

		func deleteItem(
			itemId: String,
			listId: String
		) async -> ActionResult<EquatableVoid> {
			do {
				try await itemsRepository.deleteItem(
					itemId: itemId,
					listId: listId
				)
				return .success()
			}
			catch {
				return .failure(error)
			}
		}

		func updateItemName(
			item: Item,
			listId: String
		) async -> ActionResult<Item> {
			do {
				let updatedItem = try await itemsRepository.updateItem(
					item: item,
					listId: listId
				)

				return .success(updatedItem)
			}
			catch {
				return .failure(error)
			}
		}

		func updateItemDone(
			item: Item,
			list: UserList
		) async -> ActionResult<Item> {
			do {
				let updatedItem = try await itemsRepository.updateItem(
					item: item,
					listId: list.documentId
				)

				_ = try await listsRepository.updateList(list)

				return .success(updatedItem)
			}
			catch {
				return .failure(error)
			}
		}

		func sortItems(
			items: [Item],
			listId: String
		) async -> ActionResult<EquatableVoid> {
			do {
				try await itemsRepository.sortItems(
					items: items,
					listId: listId
				)
				return .success()
			}
			catch {
				return .failure(error)
			}
		}
	}
}
