import SwiftUI

struct HomeBuilder {
    @MainActor
    static func makeHome() -> HomeView {
        let viewModel = HomeViewModel()
        return HomeView(viewModel: viewModel)
    }
}
