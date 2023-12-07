import SwiftUI

struct ProductsBuilder {
    @MainActor
    static func makeProductList(
        list: List,
        productsRepository: ProductsRepositoryApi = ProductsRepository()
    ) -> ProductsView {
        let viewModel = ProductsViewModel(list: list,
                                          productsRepository: productsRepository)
        return ProductsView(viewModel: viewModel)
    }
}
