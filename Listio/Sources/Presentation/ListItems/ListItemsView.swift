import SwiftUI

// MARK: - ListItemsView

private struct ListActions: ListRowsViewActions {
    var tapAction: ((any ListRow) -> Void)?
    var swipeActions: ((Int, ListRowActionType) -> Void)?
    var submitAction: ((String) -> Void)?
    var cancelAction: (() -> Void)?
}

struct ListItemsView: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    private var listName: String
    
    init(
        store: Store<ListItems.Reducer>,
        listName: String) {
            self.store = store
            self.listName = listName
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                ScrollViewReader { scrollView in
                    SwiftUI.List {
                        ListRowsView(viewModel: store.state.viewModel,
                                     actions: listActions,
                                     newRowPlaceholder: Constants.Text.item)
                        
                    }.onChange(of: store.state.viewState == .addingItem, {
                        withAnimation {
                            scrollView.scrollTo(store.state.viewModel.rows.count - 1,
                                                anchor: .bottom)
                        }
                    })
                }
                addNewRowButton
            }
            .task {
                store.send(.onAppear)
            }
            .disabled(store.state.viewState == .loading)
            if store.state.viewState == .loading {
                ProgressView()
            }
        }
        .alert(isPresented: Binding(
            get: { store.state.viewState == .unexpectedError },
            set: { _ in }
        )) {
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: Text(Constants.Text.unexpectedError),
                dismissButton: .default(Text(Constants.Text.errorOkButton)) {
                    store.send(.didTapDismissError)
                }
            )
        }
        .navigationTitle(listName)
    }
}

// MARK: - Private

private extension ListItemsView {
    @ViewBuilder
    var addNewRowButton: some View {
        if store.state.viewState != .addingItem {
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
    var listActions: ListActions {
        ListActions(swipeActions: swipeActions,
                    submitAction: submitAction,
                    cancelAction: cancelAction)
    }
    
    var swipeActions: (Int, ListRowActionType) -> Void {
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
        { store.send(.didTapSubmitItemButton($0)) }
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
            static let errorTitle = "Error"
            static let unexpectedError = "Unexpected error"
            static let errorOkButton = "Ok"
            
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
