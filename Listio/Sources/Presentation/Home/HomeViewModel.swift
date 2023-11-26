import FirebaseFirestore
import FirebaseFirestoreSwift

final class HomeViewModel: ItemsViewModel {
    @Published var items: [ItemModel] = []
    internal var options: [ItemOption] {
        [ItemOption(type: .share,
                    action: shareList),
         ItemOption(type: .done,
                    action: finishList),
         ItemOption(type: .delete,
                    action: deleteList)]
    }
    @Published var isLoading = false
    private let listsRepository: ListsRepositoryApi
    
    init(listsRepository: ListsRepositoryApi) {
        self.listsRepository = listsRepository
    }
    
    func fetchLists() {
        isLoading = true
        listsRepository.fetchLists { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let lists):
                self?.items = lists
            case .failure:
                break
            }
        }
    }
    
    var shareList: (String?) -> Void {
        { id in
            
        }
    }
    
    var finishList: (String?) -> Void {
        { id in
            
        }
    }
    
    var deleteList: (String?) -> Void {
        { [weak self] id in
            guard let list = self?.items.first(where: { $0.id == id }) as? ListDTO else {
                return
            }
            self?.listsRepository.deleteList(list)
        }
    }
}

extension ListDTO: ItemModel {}
