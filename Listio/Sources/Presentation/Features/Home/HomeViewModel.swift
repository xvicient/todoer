import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class HomeViewModel: ItemsViewModel {
    @Published var items: [any ItemModel] = []
    internal var options: (any ItemModel) -> [ItemOption] {
        { [weak self] item in
            guard let self = self else { return [] }
            return [ItemOption(type: .share,
                               action: shareList),
                    ItemOption(type: item.done ? .undone : .done,
                               action: toggleList),
                    ItemOption(type: .delete,
                               action: deleteList)]
        }
    }
    @Published var isLoading = false
    private let listsRepository: ListsRepositoryApi
    private let productsRepository: ProductsRepositoryApi
    
    init(listsRepository: ListsRepositoryApi = ListsRepository(),
         productsRepository: ProductsRepositoryApi = ProductsRepository()) {
        self.listsRepository = listsRepository
        self.productsRepository = productsRepository
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
    
    var toggleList: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self,
                  var list = item as? ListModel else { return }
            list.done.toggle()
            self.listsRepository.toggleList(list) { result in
                switch result {
                case .success:
                    self.productsRepository.toogleAllProductsBatch(
                        listId: list.documentId,
                        done: list.done) { _ in }
                case .failure:
                    break
                }
            }
        }
    }
    
    var deleteList: (any ItemModel) -> Void {
        { [weak self] item in
            self?.listsRepository.deleteList(item.documentId)
        }
    }
}

extension ListModel: ItemModel {}
