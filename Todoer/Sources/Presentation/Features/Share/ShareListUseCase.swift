import Combine
import Foundation

protocol ShareListUseCaseApi {
	func fetchUsers(
		uids: [String]
	) async -> ActionResult<[User]>

	func shareList(
		shareEmail: String,
		list: List
	) async -> ActionResult<EquatableVoid>
}

extension ShareList {
	struct UseCase: ShareListUseCaseApi {
		private enum Errors: Error, LocalizedError {
			case emailNotFound
			case unexpectedError

			var errorDescription: String? {
				switch self {
				case .emailNotFound:
					return "Email not found."
				case .unexpectedError:
					return "Unexpected error."
				}
			}
		}

		private let usersRepository: UsersRepositoryApi
		private let invitationsRepository: InvitationsRepositoryApi

		init(
			usersRepository: UsersRepositoryApi = UsersRepository(),
			invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()
		) {
			self.usersRepository = usersRepository
			self.invitationsRepository = invitationsRepository
		}

		func fetchUsers(
			uids: [String]
		) async -> ActionResult<[User]> {
			do {
				let result = try await usersRepository.getNotSelfUsers(uids: uids)
				return .success(result)
			}
			catch {
				return .failure(error)
			}
		}

		func shareList(
			shareEmail: String,
			list: List
		) async -> ActionResult<EquatableVoid> {
			do {
				guard let invitedUser = try? await usersRepository.getUser(email: shareEmail) else {
					return .failure(Errors.emailNotFound)
				}

				guard
					(try? await invitationsRepository.getInvitation(
						invitedId: invitedUser.uid,
						listId: list.documentId
					)) == nil
				else {
					return .success()
				}

				guard let selfUser = try? await usersRepository.getSelfUser(),
					let ownerName = selfUser.displayName,
					let ownerEmail = selfUser.email
				else {
					return .failure(Errors.unexpectedError)
				}

				try await invitationsRepository.sendInvitation(
					ownerName: ownerName,
					ownerEmail: ownerEmail,
					listId: list.documentId,
					listName: list.name,
					invitedId: invitedUser.uid
				)

				return .success()
			}
			catch {
				return .failure(error)
			}
		}
	}
}
