import SwiftUI

struct ListItemsBuilder {
    @MainActor
    static func makeProductList(
        list: List,
        productsRepository: ItemsRepositoryApi = ItemsRepository()
    ) -> ListItemsView {
        let viewModel = ListItemsViewModel(list: list,
                                          productsRepository: productsRepository)
        return ListItemsView(viewModel: viewModel)
    }
}
