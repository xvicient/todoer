import Combine
import Foundation
import Data
import Application
import Entities
import Common

protocol HomeUseCaseApi {
    @MainActor
    func fetchData(
    ) -> AnyPublisher<HomeData, Error>

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
        
        @AppSetting(key: "sharedLists", defaultValue: [""]) private var sharedLists: [String]

		init(
			listsRepository: ListsRepositoryApi = ListsRepository(),
            itemsRepository: ItemsRepositoryApi = ItemsRepository(),
			invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()
		) {
			self.listsRepository = listsRepository
			self.itemsRepository = itemsRepository
			self.invitationsRepository = invitationsRepository
		}
        
        @MainActor
        func fetchData() -> AnyPublisher<HomeData, Error> {
            let addSharedListsPublisher = Future<Void, Error> { promise in
                Task { @MainActor in
                    await self.addSharedLists()
                    promise(.success(()))
                }
            }
            
            return addSharedListsPublisher
                .flatMap { _ in
                    self.fetchListsAndInvitations()
                }
                .eraseToAnyPublisher()
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
	}
}

private extension Home.UseCase {
    
    func fetchListsAndInvitations() -> AnyPublisher<HomeData, Error> {
        Publishers.CombineLatest(
            fetchLists(),
            fetchInvitations()
        )
        .map {
            HomeData(lists: $0, invitations: $1)
        }
        .eraseToAnyPublisher()
    }
    
    func addSharedLists(
    ) async {
        while !sharedLists.isEmpty {
            let name = sharedLists.removeFirst()
            _ = await addList(name: name)
        }
    }
    
	func fetchLists() -> AnyPublisher<[UserList], Error> {
		listsRepository.fetchLists()
			.map { lists in
				lists.sorted { $0.index < $1.index }
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func fetchInvitations() -> AnyPublisher<[Invitation], Error> {
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
