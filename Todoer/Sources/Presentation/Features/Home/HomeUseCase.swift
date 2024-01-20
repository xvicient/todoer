import Combine
import Foundation

protocol HomeUseCaseApi {
    func fetchData(
    ) -> AnyPublisher<([List], [Invitation]), Error>
    
    func getPhotoUrl(
    ) async -> Result<String, Error>
    
    func signOut(
    ) -> Result<Void, Error>
    
    func acceptInvitation(
        listId: String,
        invitationId: String
    ) async -> Result<Void, Error>
    
    func declineInvitation(
        invitationId: String
    ) async -> Result<Void, Error>
    
    func toggleList(
        list: List
    ) async -> Result<Void, Error>
    
    func deleteList(
        _ documentId: String
    ) async -> Result<Void, Error>
    
    func addList(
        name: String
    )  async -> Result<List, Error>
    
    func sortLists(
        lists: [List]
    ) async -> Result<Void, Error>
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
        ) -> AnyPublisher<([List], [Invitation]), Error> {
            Publishers.CombineLatest(fetchLists(),
                                     fetchInvitations())
            .map { ($0, $1) }
            .eraseToAnyPublisher()
        }
        
        func getPhotoUrl(
        ) async -> Result<String, Error> {
            do {
                let photoUrl = try await usersRepository.getSelfUser()?.photoUrl
                return .success(photoUrl ?? "")
            } catch {
                return .failure(error)
            }
        }
        
        func signOut(
        ) -> Result<Void, Error> {
            do {
                try authenticationService.signOut()
                usersRepository.setUuid("")
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func acceptInvitation(
            listId: String,
            invitationId: String
        ) async -> Result<Void, Error> {
            do {
                try await listsRepository.importList(id: listId)
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func declineInvitation(
            invitationId: String
        ) async -> Result<Void, Error> {
            do {
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func toggleList(
            list: List
        ) async -> Result<Void, Error> {
            do {
                var mutableList = list
                mutableList.done.toggle()
                try await listsRepository.toggleList(mutableList)
                try await productsRepository.toogleAllItems(
                    listId: mutableList.documentId,
                    done: mutableList.done
                )
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func deleteList(
            _ documentId: String
        ) async -> Result<Void, Error> {
            do {
                try await listsRepository.deleteList(documentId)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func addList(
            name: String
        ) async -> Result<List, Error> {
            do {
                let list = try await listsRepository.addList(with: name)
                return .success(list)
            } catch {
                return .failure(error)
            }
        }
        
        func sortLists(
            lists: [List]
        ) async -> Result<Void, Error> {
            do {
                try await listsRepository.sortLists(lists: lists)
                return .success(())
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
            .tryMap { lists in
                lists.sorted { $0.index < $1.index }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchInvitations(
    ) -> AnyPublisher<[Invitation], Error> {
        invitationsRepository.fetchInvitations()
            .tryMap { invitations in
                invitations.sorted { $0.index < $1.index }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
