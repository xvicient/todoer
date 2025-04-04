import Combine
import Common
import Data
import Entities
import Foundation
import xRedux

protocol HomeUseCaseApi {
    var sharedListsCount: Int { get }
    
    func addSharedLists() async -> ActionResult<[UserList]>
    
    func fetchHomeData() -> AnyPublisher<HomeData, Error>
    
    @discardableResult
    func updateList(
        list: UserList
    ) async -> ActionResult<UserList>
    
    func toggleList(
        list: UserList
    ) async -> ActionResult<EquatableVoid>
    
    func deleteList(
        _ listId: String
    ) async -> ActionResult<EquatableVoid>
    
    func addList(
        name: String
    ) async -> ActionResult<UserList>
    
    func sortLists(
        lists: [UserList]
    ) async -> ActionResult<EquatableVoid>
}

struct HomeData: Equatable, Sendable {
    let lists: [UserList]
    let invitations: [Invitation]
}

struct HomeUseCase: HomeUseCaseApi {
    private enum Errors: Error, LocalizedError {
        case emptyListName
        
        var errorDescription: String? {
            switch self {
            case .emptyListName:
                return "List can't be empty."
            }
        }
    }
    
    private let listsRepository: ListsRepositoryApi
    private let itemsRepository: ItemsRepositoryApi
    private let invitationsRepository: InvitationsRepositoryApi
    private let usersRepository: UsersRepositoryApi
    
    init(
        listsRepository: ListsRepositoryApi = ListsRepository(),
        itemsRepository: ItemsRepositoryApi = ItemsRepository(),
        invitationsRepository: InvitationsRepositoryApi = InvitationsRepository(),
        usersRepository: UsersRepositoryApi = UsersRepository()
    ) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.invitationsRepository = invitationsRepository
        self.usersRepository = usersRepository
    }
    
    var sharedListsCount: Int {
        listsRepository.sharedListsCount
    }
    
    func addSharedLists() async -> ActionResult<[UserList]> {
        do {
            let result = try await listsRepository.addSharedLists()
            return .success(result)
        }
        catch {
            return .failure(error)
        }
    }
    
    func fetchHomeData() -> AnyPublisher<HomeData, Error> {
        Publishers.CombineLatest(
            fetchLists(),
            fetchInvitations()
        )
        .map { lists, invitations in
            HomeData(
                lists: lists,
                invitations: invitations
            )
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    func updateList(
        list: UserList
    ) async -> ActionResult<UserList> {
        do {
            let updatedList = try await listsRepository.updateList(list)
            try await itemsRepository.toogleAllItems(
                listId: list.id,
                done: list.done
            )
            
            return .success(updatedList)
        }
        catch {
            return .failure(error)
        }
    }
    
    func toggleList(
        list: UserList
    ) async -> ActionResult<EquatableVoid> {
        await updateList(list: list)
        return .success()
    }
    
    func deleteList(
        _ listId: String
    ) async -> ActionResult<EquatableVoid> {
        do {
            try await listsRepository.deleteList(listId)
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

extension HomeUseCase {
    
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
