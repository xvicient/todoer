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
            ZStack {
                SwiftUI.List {
                    ListRowsView(viewModel: store.state.itemsModel,
                                 swipeActions: swipeActions,
                                 submitAction: submitAction,
                                 cancelAction: cancelAction,
                                 newRowPlaceholder: Constants.Text.item,
                                 cleanNewRowName: store.state.cleanNewItemName)
                    
                }
                addNewRowButton
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
    @ViewBuilder
    var addNewRowButton: some View {
        if store.state.isAddNewItemButtonVisible {
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        store.send(.didTapAddRowButton)
                    }
                }, label: {
                    Image(systemName: Constants.Image.addButton)
                        .resizable()
                        .frame(width: 48.0, height: 48.0)
                })
                .foregroundColor(.buttonPrimary)
            }
        }
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
    
    var submitAction: (String) -> Void {
        { store.send(.didTapAddItemButton($0)) }
    }
    
    var cancelAction: () -> Void {
        { store.send(.didTapCancelAddRowButton) }
    }
}

// MARK: - Constants

private extension ListItemsView {
    struct Constants {
        struct Text {
            static let item = "Item..."
        }
        struct Image {
            static let addButton = "plus.circle.fill"
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
