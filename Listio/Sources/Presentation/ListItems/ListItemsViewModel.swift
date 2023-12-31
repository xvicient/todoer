import SwiftUI

@MainActor
final class ListItemsViewModel {
    private var list: List
    let listName: String
    @Published var rows: [any ListRow] = []
    internal var options: (any ListRow) -> [ListRowAction] {
        {
            [$0.done ? .undone : .done,
             .delete]
        }
    }
    @Published var isLoading = false
    @Published var itemName: String = ""
    private let itemsRepository: ItemsRepositoryApi
    private let listsRepository: ListsRepositoryApi
    
    init(list: List,
         itemsRepository: ItemsRepositoryApi = ItemsRepository(),
         listsRepository: ListsRepositoryApi = ListsRepository()) {
        self.list = list
        listName = list.name
        self.itemsRepository = itemsRepository
        self.listsRepository = listsRepository
    }
    
    var onDidTapOption: ((any ListRow, ListRowAction) -> Void) {
        { [weak self] item, option in
            guard let self = self else { return }
            switch option {
            case .done, .undone:
//                self.toggleItem(item)
                break
            case .delete:
                break
            default: break
            }
        }
    }
    
//    private func toggleItem(_ item: any ListRow) {
//        guard var listItem = item as? Item else { return }
//        listItem.done.toggle()
//        itemsRepository.toggleItem(listItem,
//                                   listId: list.documentId) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                list.done = self.rows.allSatisfy({ $0.done })
//                listsRepository.toggleList(list, completion: { _ in })
//                break
//            case .failure:
//                break
//            }
//        }
//    }
}
