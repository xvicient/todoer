import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol InvitationsDataSourceApi {
	func getInvitations(
		with fields: [InvitationsDataSource.SearchField]
	) -> AnyPublisher<[InvitationDTO], Error>

	func getInvitations(
		with fields: [InvitationsDataSource.SearchField]
	) async throws -> [InvitationDTO]

	func sendInvitation(
		ownerName: String,
		ownerEmail: String,
		listId: String,
		listName: String,
		invitedId: String
	) async throws

	func deleteInvitation(
		_ documentId: String
	) async throws
}

final class InvitationsDataSource: InvitationsDataSourceApi {

	struct SearchField {
		enum Key: String {
			case invitedId
			case listId
		}
		enum Filter {
			case equal(String)
		}
		let key: Key
		let filter: Filter

		init(_ key: Key, _ filter: Filter) {
			self.key = key
			self.filter = filter
		}
	}

	private var snapshotListener: ListenerRegistration?
	private var listenerSubject: PassthroughSubject<[InvitationDTO], Error>?

	private let invitationsCollection = Firestore.firestore().collection("invitations")

	deinit {
		snapshotListener?.remove()
		listenerSubject = nil
	}

	func getInvitations(
		with fields: [SearchField]
	) -> AnyPublisher<[InvitationDTO], Error> {
		let subject = PassthroughSubject<[InvitationDTO], Error>()
		listenerSubject = subject

		invitationsQuery(with: fields)
			.addSnapshotListener { query, error in
				if let error = error {
					subject.send(completion: .failure(error))
					return
				}

				let invitations =
					query?.documents
					.compactMap { try? $0.data(as: InvitationDTO.self) }
					?? []

				subject.send(invitations)
			}

		return
			subject
			.removeDuplicates()
			.eraseToAnyPublisher()
	}

	func getInvitations(
		with fields: [SearchField]
	) async throws -> [InvitationDTO] {
		try await invitationsQuery(with: fields)
			.getDocuments()
			.documents
			.map { try $0.data(as: InvitationDTO.self) }
	}

	func sendInvitation(
		ownerName: String,
		ownerEmail: String,
		listId: String,
		listName: String,
		invitedId: String
	) async throws {
		let dto = InvitationDTO(
			ownerName: ownerName,
			ownerEmail: ownerEmail,
			listId: listId,
			listName: listName,
			invitedId: invitedId,
			index: Date().milliseconds
		)
		try invitationsCollection.addDocument(from: dto)
	}

	func deleteInvitation(
		_ documentId: String
	) async throws {
		try await invitationsCollection.document(documentId).delete()
	}

	private func invitationsQuery(
		with fields: [SearchField]
	) -> Query {
		var query: Query = invitationsCollection

		fields.forEach {
			switch $0.filter {
			case .equal(let value):
				query = query.whereField($0.key.rawValue, isEqualTo: value)
			}
		}

		return query
	}
}
