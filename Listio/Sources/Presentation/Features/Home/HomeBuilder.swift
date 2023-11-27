import SwiftUI

struct HomeBuilder {
    @MainActor
    static func makeHome(
        listsRepository: ListsRepositoryApi = ListsRepository()
    ) -> HomeView {
        let viewModel = HomeViewModel(listsRepository: listsRepository)
        return HomeView(viewModel: viewModel)
    }
}