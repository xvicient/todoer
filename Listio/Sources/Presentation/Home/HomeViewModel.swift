import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class HomeViewModel: ObservableObject {
    @Published var lists: [ListDTO] = []
    @Published var isLoading = false
    @Published var listName: String = ""
    @Published var listId: String = ""
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
                self?.lists = lists
            case .failure:
                break
            }
        }
    }
    
    func addList() {
        guard !listName.isEmpty else { return }
        isLoading = true
        listsRepository.addList(with: listName) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.listName = ""
            case .failure:
                break
            }
        }
    }
    
    func deleteList(at indexSet: IndexSet) {
        guard let index = indexSet.first,
              let list = lists[safe: index] else { return }
        listsRepository.deleteList(list)
    }
    
    func productsView(listId: String?,
                      listName: String) -> ProductsView? {
        guard let listId = listId else { return nil }
        return ProductsBuilder.makeProductList(listId: listId,
                                               listName: listName,
                                               productsRepository: ProductsRepository())
    }
    
    func importList() {
        
    }
}
