import SwiftUI

struct ListItemsView: View {
    @StateObject var viewModel: ListItemsViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                SwiftUI.List {
                    ItemsRowView(viewModel: viewModel,
                              optionsAction: viewModel.onDidTapOption)
                    
                }
                TextField("Add product...",
                          text: $viewModel.itemName)
                .textFieldStyle(BottomLineStyle() {
                    viewModel.addItem()
                })
            }
            .task {
                viewModel.fetchItems()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle(viewModel.listName)
    }
}

#Preview {
    ListItemsView(viewModel:
                    ListItemsViewModel(
                        list: List(documentId: "",
                                   name: "",
                                   done: false,
                                   uuid: [],
                                   dateCreated: 0)
                    )
    )
}
