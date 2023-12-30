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
                    ListRowsView(viewModel: store.state.itemsModel,
                                 swipeActions: swipeActions)
                    
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

private extension ListItemsView {
    var swipeActions: (any ListRowsModel, ListRowOption) -> Void {
        { item, option in
            switch option {
            case .done:
                store.send(.didTapDoneButton(item))
            case .undone:
                store.send(.didTapUndoneButton(item))
            case .delete:
                store.send(.didTapDeleteButton(item))
            case .share:
                break
            }
        }
    }
}

#Preview {
    ListItems.Builder.makeItemsList(
        list: List(
            documentId: "1",
            name: "Test",
            done: false,
            uuid: [""],
            dateCreated: 1)
    )
}
