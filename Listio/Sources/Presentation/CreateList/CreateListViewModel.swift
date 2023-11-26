import SwiftUI

final class CreateListViewModel: ObservableObject {
    @Published var listName: String = ""
    private let listsRepository: ListsRepositoryApi
    
    init(listsRepository: ListsRepositoryApi) {
        self.listsRepository = listsRepository
    }
    
    func createList() {
        guard !listName.isEmpty else { return }
        listsRepository.addList(with: listName) {
            switch $0 {
            case .success: break
            case .failure: break
            }
        }
    }
}
