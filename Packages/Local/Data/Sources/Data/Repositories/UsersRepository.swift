protocol UsersRepositoryApi {

	func setUid(_ value: String)

	func createUser(
		with uid: String,
		email: String?,
		displayName: String?,
		photoUrl: String?,
		provider: String
	) async throws

	func getSelfUser() async throws -> User?

	func getUser(
		uid: String
	) async throws -> User?

	func getUser(
		email: String
	) async throws -> User?

	func getNotSelfUser(
		email: String,
		uid: String
	) async throws -> User?

	func getNotSelfUsers(
		uids: [String]
	) async throws -> [User]

	func deleteUser() async throws
}

final class UsersRepository: UsersRepositoryApi {

	typealias SearchField = UsersDataSource.SearchField

	var usersDataSource: UsersDataSourceApi

	init(usersDataSource: UsersDataSourceApi = UsersDataSource()) {
		self.usersDataSource = usersDataSource
	}

	func setUid(_ value: String) {
		usersDataSource.uid = value
	}

	func createUser(
		with uid: String,
		email: String?,
		displayName: String?,
		photoUrl: String?,
		provider: String
	) async throws {
		try await usersDataSource.createUser(
			with: uid,
			email: email,
			displayName: displayName,
			photoUrl: photoUrl,
			provider: provider
		)
	}

	func getSelfUser() async throws -> User? {
		try await usersDataSource.getUsers(
			with: [SearchField(.uid, .equal(usersDataSource.uid))]
		)
		.first?
		.toDomain
	}

	func getUser(
		uid: String
	) async throws -> User? {
		try await usersDataSource.getUsers(
			with: [SearchField(.uid, .equal(uid))]
		)
		.first?
		.toDomain
	}

	func getUser(
		email: String
	) async throws -> User? {
		try await usersDataSource.getUsers(
			with: [SearchField(.email, .equal(email))]
		)
		.first?
		.toDomain
	}

	func getNotSelfUser(
		email: String,
		uid: String
	) async throws -> User? {
		try await usersDataSource.getUsers(
			with: [
				SearchField(.email, .equal(email)),
				SearchField(.uid, .notEqual(uid)),
			]
		)
		.first?
		.toDomain
	}

	func getNotSelfUsers(
		uids: [String]
	) async throws -> [User] {
		let notSelfUids = uids.filter { $0 != usersDataSource.uid }

		if notSelfUids.isEmpty {
			return []
		}
		else {
			return try await usersDataSource.getUsers(
				with: [SearchField(.uid, .in(notSelfUids))]
			)
			.map { $0.toDomain }
		}
	}

	func deleteUser() async throws {
		try await usersDataSource.deleteUser()
	}
}
