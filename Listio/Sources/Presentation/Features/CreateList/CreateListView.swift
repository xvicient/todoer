import SwiftUI

struct CreateListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: CreateListViewModel
    
    var body: some View {
        VStack {
            TextField("Add List...",
                      text: $viewModel.listName)
            .textFieldStyle(BottomLineStyle() {
                viewModel.createList()
                coordinator.dismissSheet()
            })
        }
    }
}

#Preview {
    CreateListView(viewModel: CreateListViewModel(listsRepository: ListsRepository()))
}
