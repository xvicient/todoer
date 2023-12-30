import SwiftUI

// MARK: - ListItemsView

struct ListItemsView: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    
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
                TextField(Constants.Text.itemName,
                          text: Binding(
                            get: { store.state.newItemName },
                            set: { store.send(.setNewItemName($0)) }
                        ))
                .textFieldStyle(BottomLineStyle() {
                    store.send(.didTapAddItemButton)
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

// MARK: - Private

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

// MARK: - Constants

private extension ListItemsView {
    struct Constants {
        struct Text {
            static let itemName = "Item name..."
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
