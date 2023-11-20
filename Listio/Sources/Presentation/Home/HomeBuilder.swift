import SwiftUI

struct HomeBuilder {
    static func makeHome(
        productsRepository: ProductsRepositoryApi = ProductsRepository()
    ) -> HomeView {
        let viewModel = HomeViewModel(productsRepository: productsRepository)
        return HomeView(viewModel: viewModel)
    }
}
