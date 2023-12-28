import SwiftUI

struct ListItemsView: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    @State var itemName: String = ""
    
    init(store: Store<ListItems.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                SwiftUI.List {
                    ItemsRowView(viewModel: store.state.itemsModel,
                                 optionsAction: { _,_ in
                        // TODO: - move viewModel.onDidTapOption to redux
                    })
                    
                }
                TextField("Add product...",
                          text: $itemName)
                .textFieldStyle(BottomLineStyle() {
                    store.send(.didTapAddItemButton(itemName))
                })
            }
            .task {
                store.send(.viewWillAppear)
            }
            .disabled(store.state.isLoading)
            if store.state.isLoading {
                ProgressView()
            }
        }
        .navigationTitle(store.state.listName)
    }
}

#Preview {
    ListItems.Builder.makeProductList(
        list: List(
            documentId: "1",
            name: "Test",
            done: false,
            uuid: [""],
            dateCreated: 1)
    )
}
