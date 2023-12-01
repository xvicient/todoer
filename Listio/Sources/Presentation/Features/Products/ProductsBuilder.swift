import SwiftUI

struct ProductsBuilder {
    @MainActor
    static func makeProductList(
        list: ListModel,
        productsRepository: ProductsRepositoryApi = ProductsRepository()
    ) -> ProductsView {
        let viewModel = ProductsViewModel(list: list,
                                          productsRepository: productsRepository)
        return ProductsView(viewModel: viewModel)
    }
}
