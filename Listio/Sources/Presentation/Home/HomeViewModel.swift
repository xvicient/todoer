import SwiftUI

// MARK: - HomeViewModelApi

protocol HomeViewModelApi {
    func fetchData()
    var onDidTapOption: ((any ListRowsModel, ListRowOption) -> Void) { get }
    func shareList() async
    func cancelShare()
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
    @Published var rows: [any ListRowsModel] = []
    internal var leadingActions: (any ListRowsModel) -> [ListRowOption] {
        {
            [$0.done ? .undone : .done]
        }
    }
    internal var trailingActions: [ListRowOption] = [.share, .delete]
    @Published var isLoading = false
    @Published var shareEmail: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var userSelfPhoto: String = ""
    @Published var listName: String = ""
    @Published var isShowingAddButton: Bool = true
    @Published var isShowingAddTextField: Bool = false
    
    private var sharingList: List?
    
    private let listsRepository: ListsRepositoryApi
    private let productsRepository: ItemsRepositoryApi
    private let invitationsRepository: InvitationsRepositoryApi
    private let usersDataRepository: UsersRepositoryApi
    private let authenticationService: AuthenticationService
    
    init(listsRepository: ListsRepositoryApi = ListsRepository(),
         productsRepository: ItemsRepositoryApi = ItemsRepository(),
         invitationsRepository: InvitationsRepositoryApi = InvitationsRepository(),
         usersDataRepository: UsersRepositoryApi = UsersRepository(),
         authenticationService: AuthenticationService = AuthenticationService()) {
        self.listsRepository = listsRepository
        self.productsRepository = productsRepository
        self.invitationsRepository = invitationsRepository
        self.usersDataRepository = usersDataRepository
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
    
    var onDidTapOption: ((any ListRowsModel, ListRowOption) -> Void) {
        { [weak self] item, option in
            guard let self = self else { return }
            switch option {
            case .share:
                self.showShareDialog(item)
            case .done, .undone:
                self.toggleList(item)
            case .delete:
                self.deleteList(item)
            }
        }
    }
    
    func shareList() async {
        isShowingAlert = false
        
        if let selfUser = try? await usersDataRepository.getSelfUser(),
           let ownerName = selfUser.displayName,
           let ownerEmail = selfUser.email,
           let invitedUser = try? await usersDataRepository.getUser(shareEmail),
           let listId = sharingList?.documentId,
           let listName = sharingList?.name  {
            invitationsRepository.sendInvitation(ownerName: ownerName,
                                                 ownerEmail: ownerEmail,
                                                 listId: listId,
                                                 listName: listName,
                                                 invitedId: invitedUser.uuid) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
    func cancelShare() {
        sharingList = nil
        shareEmail = ""
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
                self?.isShowingAddButton = false
            }
        }
    }
    
    func signOut() {
        try? authenticationService.signOut()
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
            guard let photoUrl = try? await usersDataRepository.getSelfUser().photoUrl else {
                return
            }
            userSelfPhoto = photoUrl
        }
    }
    
    func showShareDialog(_ item: any ListRowsModel) {
        guard let list = item as? List else { return }
        sharingList = list
        isShowingAlert = true
    }
    
    func toggleList(_ item: any ListRowsModel) {
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
    
    func deleteList(_ item: any ListRowsModel) {
        listsRepository.deleteList(item.documentId)
    }
}

extension List: ListRowsModel {}
