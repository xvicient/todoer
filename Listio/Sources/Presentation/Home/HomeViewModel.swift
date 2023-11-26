import FirebaseFirestore
import FirebaseFirestoreSwift

enum ListOptions: String, CaseIterable {
    case share = "Share"
    case markAsDone = "Mark as done"
    case delete = "Delete"
}

final class HomeViewModel: ObservableObject {
    @Published var lists: [ListDTO] = []
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
                self?.lists = lists
            case .failure:
                break
            }
        }
    }
    
    func addList() {
//        guard !listName.isEmpty else { return }
//        isLoading = true
//        listsRepository.addList(with: listName) { [weak self] result in
//            self?.isLoading = false
//            switch result {
//            case .success:
//                self?.listName = ""
//            case .failure:
//                break
//            }
//        }
    }
    
    func addMember(to list: ListDTO) {}
    
    func markDone(to list: ListDTO) {}
    
    func deleteList(_ list: ListDTO) {
        listsRepository.deleteList(list)
    }
    
    func importList() {
//        guard !listId.isEmpty else { return }
//        listsRepository.importList(id: listId)
    }
}
