import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - HomeViewModelApi

protocol HomeViewModelApi {
    func fetchData()
    var onDidTapOption: ((any ItemModel, ItemOption) -> Void) { get }
    func shareList() async
    func cancelShare()
    func importList(
        listId: String,
        invitationId: String
    )
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ItemsViewModel {
    @Published var invitations: [InvitationModel] = []
    @Published var items: [any ItemModel] = []
    internal var options: (any ItemModel) -> [ItemOption] {
        {
            [.share,
             $0.done ? .undone : .done,
             .delete]
        }
    }
    @Published var isLoading = false
    @Published var shareEmail: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var userSelfPhoto: String = ""
    
    private var sharingList: ListModel?
    
    private let listsRepository: ListsRepositoryApi
    private let productsRepository: ProductsRepositoryApi
    private let invitationsRepository: InvitationsRepositoryApi
    private let usersDataRepository: UsersRepositoryApi
    
    init(listsRepository: ListsRepositoryApi = ListsRepository(),
         productsRepository: ProductsRepositoryApi = ProductsRepository(),
         invitationsRepository: InvitationsRepositoryApi = InvitationsRepository(),
         usersDataRepository: UsersRepositoryApi = UsersRepository()) {
        self.listsRepository = listsRepository
        self.productsRepository = productsRepository
        self.invitationsRepository = invitationsRepository
        self.usersDataRepository = usersDataRepository
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
    
    var onDidTapOption: ((any ItemModel, ItemOption) -> Void) {
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
}

// MARK: - Private

private extension HomeViewModel {
    func fetchLists() {
        listsRepository.fetchLists { [weak self] result in
            switch result {
            case .success(let lists):
                self?.items = lists.sorted {
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
    
    func showShareDialog(_ item: any ItemModel) {
        guard let list = item as? ListModel else { return }
        sharingList = list
        isShowingAlert = true
    }
    
    func toggleList(_ item: any ItemModel) {
        guard var list = item as? ListModel else { return }
        
        list.done.toggle()
        listsRepository.toggleList(list) { [weak self] result in
            switch result {
            case .success:
                self?.productsRepository.toogleAllProductsBatch(
                    listId: list.documentId,
                    done: list.done,
                    completion: { _ in})
            case .failure:
                break
            }
        }
    }
    
    func deleteList(_ item: any ItemModel) {
        listsRepository.deleteList(item.documentId)
    }
}

extension ListModel: ItemModel {}
