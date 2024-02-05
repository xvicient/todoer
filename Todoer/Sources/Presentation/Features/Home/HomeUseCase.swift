import Combine
import Foundation

protocol HomeUseCaseApi {
    func fetchData(
    ) -> AnyPublisher<HomeData, Error>
    
    func getPhotoUrl(
    ) async -> ActionResult<String>
    
    func signOut(
    ) -> ActionResult<EquatableVoid>
    
    func acceptInvitation(
        listId: String,
        invitationId: String
    ) async -> ActionResult<EquatableVoid>
    
    func declineInvitation(
        invitationId: String
    ) async -> ActionResult<EquatableVoid>
    
    func updateList(
        list: List
    ) async -> ActionResult<List>
    
    func deleteList(
        _ documentId: String
    ) async -> ActionResult<EquatableVoid>
    
    func addList(
        name: String
    )  async -> ActionResult<List>
    
    func sortLists(
        lists: [List]
    ) async -> ActionResult<EquatableVoid>
    
    func deleteAccount(
    ) async -> ActionResult<EquatableVoid>
}

extension Home {
    struct UseCase: HomeUseCaseApi {
        private let listsRepository: ListsRepositoryApi
        private let productsRepository: ItemsRepositoryApi
        private let invitationsRepository: InvitationsRepositoryApi
        private let usersRepository: UsersRepositoryApi
        private let authenticationService: AuthenticationService
        
        init(listsRepository: ListsRepositoryApi = ListsRepository(),
             productsRepository: ItemsRepositoryApi = ItemsRepository(),
             invitationsRepository: InvitationsRepositoryApi = InvitationsRepository(),
             usersRepository: UsersRepositoryApi = UsersRepository(),
             authenticationService: AuthenticationService = AuthenticationService()) {
            self.listsRepository = listsRepository
            self.productsRepository = productsRepository
            self.invitationsRepository = invitationsRepository
            self.usersRepository = usersRepository
            self.authenticationService = authenticationService
        }
        
        func fetchData(
        ) -> AnyPublisher<HomeData, Error> {
            Publishers.CombineLatest(fetchLists(),
                                     fetchInvitations())
            .map { HomeData(lists: $0, invitations: $1) }
            .eraseToAnyPublisher()
        }
        
        func getPhotoUrl(
        ) async -> ActionResult<String> {
            do {
                let photoUrl = try await usersRepository.getSelfUser()?.photoUrl
                return .success(photoUrl ?? "")
            } catch {
                return .failure(error)
            }
        }
        
        func signOut(
        ) -> ActionResult<EquatableVoid> {
            do {
                try authenticationService.signOut()
                usersRepository.setUuid("")
                return .success()
            } catch {
                return .failure(error)
            }
        }
        
        func acceptInvitation(
            listId: String,
            invitationId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await listsRepository.importList(id: listId)
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success()
            } catch {
                return .failure(error)
            }
        }
        
        func declineInvitation(
            invitationId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success()
            } catch {
                return .failure(error)
            }
        }
        
        func updateList(
            list: List
        ) async -> ActionResult<List> {
            do {
                let updatedList = try await listsRepository.updateList(list)
                try await productsRepository.toogleAllItems(
                    listId: list.documentId,
                    done: list.done
                )
                return .success(updatedList)
            } catch {
                return .failure(error)
            }
        }
        
        func deleteList(
            _ documentId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await listsRepository.deleteList(documentId)
                return .success()
            } catch {
                return .failure(error)
            }
        }
        
        func addList(
            name: String
        ) async -> ActionResult<List> {
            do {
                let list = try await listsRepository.addList(with: name)
                return .success(list)
            } catch {
                return .failure(error)
            }
        }
        
        func sortLists(
            lists: [List]
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await listsRepository.sortLists(lists: lists)
                return .success()
            } catch {
                return .failure(error)
            }
        }
        
        func deleteAccount(
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await usersRepository.deleteUser()
                try await listsRepository.deleteSelfUserLists()
                return .success()
            } catch {
                return .failure(error)
            }
        }
    }
}

private extension Home.UseCase {
    func fetchLists(
    ) -> AnyPublisher<[List], Error> {
        listsRepository.fetchLists()
            .map { lists in
                lists.sorted { $0.index < $1.index }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchInvitations(
    ) -> AnyPublisher<[Invitation], Error> {
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

private extension String {
    var isAppleInternalEmail: Bool {
        contains("privaterelay.appleid.com")
    }
}
