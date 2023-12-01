import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class HomeViewModel: ItemsViewModel {
    @Published var items: [any ItemModel] = []
    internal var options: [ItemOption] {
        [ItemOption(type: .share,
                    action: shareList),
         ItemOption(type: .doneUndone,
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
                self?.items = lists.sorted {
                    $0.dateCreated < $1.dateCreated
                }
            case .failure:
                break
            }
        }
    }
    
    var shareList: (any ItemModel) -> Void {
        { item in
            
        }
    }
    
    var finishList: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self,
                  var list = item as? ListModel else { return }
            list.done.toggle()
            self.listsRepository.finishList(list) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
    var deleteList: (any ItemModel) -> Void {
        { [weak self] item in
            guard let documentId = item.documentId else {
                return
            }
            self?.listsRepository.deleteList(documentId)
        }
    }
}

extension ListModel: ItemModel {}
