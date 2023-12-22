import SwiftUI

struct ListItemsBuilder {
    @MainActor
    static func makeProductList(
        list: List
    ) -> ListItemsView {
        let viewModel = ListItemsViewModel(list: list)
        return ListItemsView(viewModel: viewModel)
    }
}
