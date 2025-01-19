import Combine
import Foundation
import Data
import Application
import Entities

protocol ShareListUseCaseApi {
	func fetchData(
		uids: [String]
	) async -> ActionResult<ShareData>

	func shareList(
		shareEmail: String,
        ownerName: String,
		list: UserList
	) async -> ActionResult<EquatableVoid>
}

extension ShareList {
    struct ShareData: Equatable, Sendable {
        let users: [User]
        let selfName: String?
    }
    
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

		func fetchData(
			uids: [String]
		) async -> ActionResult<ShareData> {
			do {
				let users = try await usersRepository.getNotSelfUsers(uids: uids)
                let displayName = try? await usersRepository.getSelfUser()?.displayName
                return .success(ShareData(users: users, selfName: displayName))
			}
			catch {
				return .failure(error)
			}
		}

		func shareList(
			shareEmail: String,
            ownerName: String,
			list: UserList
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

				guard
                    let selfUser = try? await usersRepository.getSelfUser(),
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
