import SwiftUI

// MARK: - HomeViewModelApi

protocol HomeViewModelApi {
    func fetchData()
    var onDidTapOption: ((Int, ListRowAction) -> Void) { get }
    func importList(
        listId: String,
        invitationId: String
    )
    func createList()
    func signOut()
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ListRowsViewModel {
    @Published var invitations: [Invitation] = []
    @Published var rows: [any ListRow] = []
    internal var leadingActions: (any ListRow) -> [ListRowAction] {
        { [$0.done ? .undone : .done] }
    }
    internal var trailingActions: [ListRowAction] = [.share, .delete]
    @Published var isLoading = false
    @Published var userSelfPhoto: String = ""
    @Published var listName: String = ""
    @Published var isShowingAddButton: Bool = true
    @Published var isShowingAddTextField: Bool = false
    
    private var sharingList: List?
    
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
}

// MARK: - HomeViewModelApi implementation

extension HomeViewModel: HomeViewModelApi {
    func fetchData() {
        isLoading = true
        DispatchGroup().execute(
            { [weak self] in
                self?.fetchLists()
                $0()
            },
            { [weak self] in
                self?.fetchInvitations()
                $0()
            },
            { [weak self] in
                self?.fetchUserSelf()
                $0()
            },
            onComplete: { [weak self] in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
        )
    }
    
    var onDidTapOption: ((Int, ListRowAction) -> Void) {
        { [weak self] index, option in
            guard let self = self else { return }
            let item = rows[index]
            switch option {
            case .share:
                break
            case .done, .undone:
                self.toggleList(item)
            case .delete:
                self.deleteList(item)
            }
        }
    }
    
    func importList(
        listId: String,
        invitationId: String
    ) {
        listsRepository.importList(id: listId) { [weak self] result in
            switch result {
            case .success:
                self?.invitationsRepository.deleteInvitation(invitationId, completion: { _ in })
            case .failure:
                break
            }
        }
    }
    
    func createList() {
        guard !listName.isEmpty else { return }
        listsRepository.addList(with: listName) { [weak self] in
            switch $0 {
            case .success,
                    .failure:
                self?.isShowingAddButton = true
                self?.isShowingAddTextField = false
            }
        }
    }
    
    func signOut() {
        try? authenticationService.signOut()
        usersRepository.setUuid("")
    }
}

// MARK: - Private

private extension HomeViewModel {
    func fetchLists() {
        listsRepository.fetchLists { [weak self] result in
            switch result {
            case .success(let lists):
                self?.rows = lists.sorted {
                    $0.dateCreated < $1.dateCreated
                }
            case .failure:
                break
            }
        }
    }
    
    func fetchInvitations() {
        invitationsRepository.fetchInvitations() { [weak self] result in
            switch result {
            case .success(let invitations):
                self?.invitations = invitations.sorted {
                    $0.dateCreated < $1.dateCreated
                }
            case .failure:
                break
            }
        }
    }
    
    func fetchUserSelf() {
        Task {
            guard let photoUrl = try? await usersRepository.getSelfUser().photoUrl else {
                return
            }
            userSelfPhoto = photoUrl
        }
    }
    
    func toggleList(_ item: any ListRow) {
        guard var list = item as? List else { return }
        
        list.done.toggle()
        listsRepository.toggleList(list) { [weak self] result in
            switch result {
            case .success:
                self?.productsRepository.toogleAllItemsBatch(
                    listId: list.documentId,
                    done: list.done,
                    completion: { _ in})
            case .failure:
                break
            }
        }
    }
    
    func deleteList(_ item: any ListRow) {
        listsRepository.deleteList(item.documentId)
    }
}

extension List: ListRow {}
