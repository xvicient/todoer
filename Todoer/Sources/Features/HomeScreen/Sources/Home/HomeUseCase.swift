import Combine
import Foundation
import Data
import Application
import Entities

protocol HomeUseCaseApi {
	func fetchData() -> AnyPublisher<HomeData, Error>

	func getPhotoUrl() async -> ActionResult<String>

	func signOut() -> ActionResult<EquatableVoid>

	func updateList(
		list: UserList
	) async -> ActionResult<UserList>

	func deleteList(
		_ documentId: String
	) async -> ActionResult<EquatableVoid>

	func addList(
		name: String
	) async -> ActionResult<UserList>

	func sortLists(
		lists: [UserList]
	) async -> ActionResult<EquatableVoid>

	func deleteAccount() async -> ActionResult<EquatableVoid>
}

extension Home {
    
    struct HomeData: Equatable, Sendable {
        let lists: [UserList]
        let invitations: [Invitation]
    }
    
	struct UseCase: HomeUseCaseApi {
		private enum Errors: Error, LocalizedError {
			case emptyListName

			var errorDescription: String? {
				switch self {
				case .emptyListName:
					return "UserList can't be empty."
				}
			}
		}

		private let listsRepository: ListsRepositoryApi
		private let itemsRepository: ItemsRepositoryApi
		private let invitationsRepository: InvitationsRepositoryApi
		private let usersRepository: UsersRepositoryApi
		private let authenticationService: AuthenticationService

		init(
			listsRepository: ListsRepositoryApi = ListsRepository(),
            itemsRepository: ItemsRepositoryApi = ItemsRepository(),
			invitationsRepository: InvitationsRepositoryApi = InvitationsRepository(),
			usersRepository: UsersRepositoryApi = UsersRepository(),
			authenticationService: AuthenticationService = AuthenticationService()
		) {
			self.listsRepository = listsRepository
			self.itemsRepository = itemsRepository
			self.invitationsRepository = invitationsRepository
			self.usersRepository = usersRepository
			self.authenticationService = authenticationService
		}

		func fetchData() -> AnyPublisher<HomeData, Error> {
			Publishers.CombineLatest(
				fetchLists(),
				fetchInvitations()
			)
			.map { HomeData(lists: $0, invitations: $1) }
			.eraseToAnyPublisher()
		}

		func getPhotoUrl() async -> ActionResult<String> {
			do {
				let photoUrl = try await usersRepository.getSelfUser()?.photoUrl
				return .success(photoUrl ?? "")
			}
			catch {
				return .failure(error)
			}
		}

		func signOut() -> ActionResult<EquatableVoid> {
			do {
				try authenticationService.signOut()
				usersRepository.setUid("")
				return .success()
			}
			catch {
				return .failure(error)
			}
		}

		func updateList(
			list: UserList
		) async -> ActionResult<UserList> {
			do {
				let updatedList = try await listsRepository.updateList(list)
				try await itemsRepository.toogleAllItems(
					listId: list.documentId,
					done: list.done
				)
				return .success(updatedList)
			}
			catch {
				return .failure(error)
			}
		}

		func deleteList(
			_ documentId: String
		) async -> ActionResult<EquatableVoid> {
			do {
				try await listsRepository.deleteList(documentId)
				return .success()
			}
			catch {
				return .failure(error)
			}
		}

		func addList(
			name: String
		) async -> ActionResult<UserList> {
			guard !name.isEmpty else {
				return .failure(Errors.emptyListName)
			}

			do {
				let list = try await listsRepository.addList(with: name)
				return .success(list)
			}
			catch {
				return .failure(error)
			}
		}

		func sortLists(
			lists: [UserList]
		) async -> ActionResult<EquatableVoid> {
			do {
				try await listsRepository.sortLists(lists: lists)
				return .success()
			}
			catch {
				return .failure(error)
			}
		}

		func deleteAccount() async -> ActionResult<EquatableVoid> {
			do {
				try await usersRepository.deleteUser()
				try await listsRepository.deleteSelfUserLists()
				return .success()
			}
			catch {
				return .failure(error)
			}
		}
	}
}

extension Home.UseCase {
	fileprivate func fetchLists() -> AnyPublisher<[UserList], Error> {
		listsRepository.fetchLists()
			.map { lists in
				lists.sorted { $0.index < $1.index }
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	fileprivate func fetchInvitations() -> AnyPublisher<[Invitation], Error> {
		invitationsRepository.getInvitations()
			.map { invitations in
				invitations.sorted { $0.index < $1.index }
			}
			.map { invitations in
				invitations.map {
					var invitation = $0
					if $0.ownerEmail.isAppleInternalEmail {
						invitation.ownerEmail = ""
					}
					return invitation
				}
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}

extension String {
	fileprivate var isAppleInternalEmail: Bool {
		contains("privaterelay.appleid.com")
	}
}
