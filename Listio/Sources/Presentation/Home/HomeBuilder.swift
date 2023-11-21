import SwiftUI

struct HomeBuilder {
    static func makeHome(
        listsRepository: ListsRepositoryApi = ListsRepository()
    ) -> HomeView {
        let viewModel = HomeViewModel(listsRepository: listsRepository)
        return HomeView(viewModel: viewModel)
    }
}
