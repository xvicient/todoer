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
                          text: newItemBinding)
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
    var swipeActions: (Int, ListRowAction) -> Void {
        { index, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleItemButton(index))
            case .delete:
                store.send(.didTapDeleteItemButton(index))
            case .share:
                break
            }
        }
    }
    
    var newItemBinding: Binding<String> {
        Binding(
          get: { store.state.newItemName },
          set: { store.send(.setNewItemName($0)) }
      )
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
