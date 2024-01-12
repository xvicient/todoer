import SwiftUI

// MARK: - HomeViewModelApi

protocol HomeViewModelApi {
    func fetchData()
    
    var onDidTapOption: ((Int, TDSectionRowActionType) -> Void) { get }
    
    func createList()
    
    func signOut()
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: TDListSectionViewModel {
    @Published var invitations: [Invitation] = []
    @Published var rows: [any TDSectionRow] = []
    internal var leadingActions: (any TDSectionRow) -> [TDSectionRowActionType] {
        { [$0.done ? .undone : .done] }
    }
    internal var trailingActions: [TDSectionRowActionType] = [.share, .delete]
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
    }
    
    var onDidTapOption: ((Int, TDSectionRowActionType) -> Void) {
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
    
    func toggleList(_ item: any TDSectionRow) {
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
    
    func deleteList(_ item: any TDSectionRow) {
        listsRepository.deleteList(item.documentId)
    }
}
