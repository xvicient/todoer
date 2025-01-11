import Combine
import FirebaseFirestore
import Common

protocol ItemsDataSourceApi {
	func fetchItems(
		listId: String
	) -> AnyPublisher<[ItemDTO], Error>

	func addItem(
		with name: String,
		listId: String
	) async throws -> ItemDTO

	func deleteItem(
		itemId: String,
		listId: String
	) async throws

	func updateItem(
		item: ItemDTO,
		listId: String
	) async throws -> ItemDTO

	func toogleAllItems(
		listId: String?,
		done: Bool
	) async throws

	func sortItems(
		items: [ItemDTO],
		listId: String
	) async throws
}

final class ItemsDataSource: ItemsDataSourceApi {
	private enum Errors: Error {
		case invalidDTO
		case encodingError
	}

	private var snapshotListener: ListenerRegistration?
	private var listenerSubject: PassthroughSubject<[ItemDTO], Error>?

	deinit {
		snapshotListener?.remove()
		listenerSubject = nil
	}

	private func itemsCollection(listId: String) -> CollectionReference {
		Firestore.firestore().collection("lists").document(listId).collection("items")
	}

	func fetchItems(
		listId: String
	) -> AnyPublisher<[ItemDTO], Error> {
		let subject = PassthroughSubject<[ItemDTO], Error>()
		listenerSubject = subject

		snapshotListener = itemsCollection(listId: listId)
			.addSnapshotListener { query, error in
				if let error = error {
					subject.send(completion: .failure(error))
					return
				}

				let products =
					query?.documents
					.compactMap { try? $0.data(as: ItemDTO.self) }
					?? []

				subject.send(products)
			}

		return
			subject
			.removeDuplicates()
			.eraseToAnyPublisher()

	}

	func addItem(
		with name: String,
		listId: String
	) async throws -> ItemDTO {
		do {
			let dto = ItemDTO(
				name: name,
				done: false,
				index: Date().milliseconds
			)
			return try await itemsCollection(listId: listId)
				.addDocument(from: dto)
				.getDocument()
				.data(as: ItemDTO.self)
		}
		catch {
			throw (error)
		}
	}

	func deleteItem(
		itemId: String,
		listId: String
	) async throws {
		try await itemsCollection(listId: listId).document(itemId).delete()
	}

	func updateItem(
		item: ItemDTO,
		listId: String
	) async throws -> ItemDTO {
		guard let id = item.id else {
			throw Errors.invalidDTO
		}

		guard let encodedData = try? Firestore.Encoder().encode(item) else {
			throw Errors.encodingError
		}

		try await itemsCollection(listId: listId).document(id).updateData(encodedData)
		return item
	}

	func toogleAllItems(
		listId: String?,
		done: Bool
	) async throws {
		guard let id = listId else {
			throw Errors.invalidDTO
		}

		let collection = itemsCollection(listId: id)
		let productsBatch = Firestore.firestore().batch()

		try await collection.getDocuments().documents.forEach {
			guard var dto = try? $0.data(as: ItemDTO.self) else {
				return
			}

			dto.done = done

			let encodedData = try Firestore.Encoder().encode(dto)
			productsBatch.updateData(
				encodedData,
				forDocument: collection.document($0.documentID)
			)
		}

		try await productsBatch.commit()
	}

	func sortItems(
		items: [ItemDTO],
		listId: String
	) async throws {
		let productsBatch = Firestore.firestore().batch()

		try items.enumerated().forEach { index, item in
			guard let id = item.id else {
				return
			}
			var mutableItem = item
			mutableItem.index = index

			let encodedData = try Firestore.Encoder().encode(mutableItem)
			productsBatch.updateData(
				encodedData,
				forDocument: itemsCollection(listId: listId).document(id)
			)
		}

		try await productsBatch.commit()
	}
}
