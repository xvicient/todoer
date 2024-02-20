import SwiftUI

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    private var listName: String
    
    init(
        store: Store<ListItems.Reducer>,
        listName: String
    ) {
        self.store = store
        self.listName = listName
    }
    
    var body: some View {
        ZStack {
            itemsList
            newRowButton
            loadingView
        }
        .onAppear {
            store.send(.onAppear)
        }
        .disabled(
            store.state.viewState == .loading
        )
        .navigationBarItems(
            trailing: navigationBarTrailingItems
        )
        .alert(isPresented: alertBinding) {
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: alertErrorMessage,
                dismissButton: .default(Text(Constants.Text.errorOkButton)) {
                    store.send(.didTapDismissError)
                }
            )
        }
    }
}

// MARK: - Private

private extension ListItemsScreen {
    @ViewBuilder
    var navigationBarTrailingItems: some View {
        TDOptionsMenuView(sortHandler: { store.send(.didTapAutoSortItems) })
    }
    
    @ViewBuilder
    var itemsList: some View {
        ScrollViewReader { scrollView in
            SwiftUI.List {
                Section(header: Text(listName).listRowHeaderStyle())
                {
                    ForEach(Array(store.state.viewModel.items.enumerated()),
                            id: \.element.id) { index, row in
                        if row.isEditing {
                            TDNewRowView(
                                row: row.tdRow,
                                onSubmit: { store.send(.didTapSubmitItemButton($0)) },
                                onUpdate: { store.send(.didTapUpdateItemButton(index, $0)) },
                                onCancelAdd: { store.send(.didTapCancelAddItemButton) },
                                onCancelEdit: { store.send(.didTapCancelEditItemButton(index)) }
                            )
                            .id(index)
                        } else {
                            TDRowView(
                                row: row.tdRow,
                                onSwipe: { swipeActions(index, $0) }
                            )
                            .id(index)
                        }
                    }.onMove(perform: moveItem)
                }
            }
            .listRowStyle(
                onChangeOf: store.state.viewState == .addingItem,
                count: store.state.viewModel.items.count,
                scrollView: scrollView
            )
        }
    }
    
    @ViewBuilder
    var newRowButton: some View {
        if store.state.viewState != .addingItem &&
            store.state.viewState != .editingItem {
            TDNewRowButton { store.send(.didTapAddRowButton) }
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var alertErrorMessage: Text? {
        if case let .error(error) = store.state.viewState {
            Text(error)
        }
    }
}

// MARK: - Private

private extension ListItemsScreen {
    var swipeActions: (Int, TDSwipeAction) -> Void {
        { index, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleItemButton(index))
            case .delete:
                store.send(.didTapDeleteItemButton(index))
            case .share:
                break
            case .edit:
                store.send(.didTapEditItemButton(index))
            }
        }
    }
    
    func moveItem(fromOffset: IndexSet, toOffset: Int) {
        store.send(.didSortItems(fromOffset, toOffset))
    }
    
    var alertBinding: Binding<Bool> {
        Binding(
            get: {
                if case .error = store.state.viewState { return true } else { return false }
            },
            set: { _ in }
        )
    }
}

// MARK: - ItemRow to TDRow

private extension ListItems.Reducer.ItemRow {
    var tdRow: TDRow {
        TDRow(
            name: item.name,
            image: item.done ? Image.largecircleFillCircle : Image.circle,
            strikethrough: item.done,
            leadingActions: leadingActions,
            trailingActions: trailingActions,
            isEditing: isEditing
        )
    }
}

// MARK: - Constants

private extension ListItemsScreen {
    struct Constants {
        struct Text {
            static let errorTitle = "Error"
            static let errorOkButton = "Ok"
            static let autoSort = "To-do first"
        }
    }
}

#Preview {
    ListItems.Builder.makeItemsList(
        list: List(
            documentId: "1",
            name: "Test",
            done: false,
            uid: [""],
            index: 1)
    )
}
