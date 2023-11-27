import SwiftUI

struct ProductsBuilder {
    @MainActor
    static func makeProductList(
        listId: String,
        listName: String,
        productsRepository: ProductsRepositoryApi = ProductsRepository()
    ) -> ProductsView {
        let viewModel = ProductsViewModel(listId: listId,
                                          listName: listName,
                                          productsRepository: productsRepository)
        return ProductsView(viewModel: viewModel)
    }
}