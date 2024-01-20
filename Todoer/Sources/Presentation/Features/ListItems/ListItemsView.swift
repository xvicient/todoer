import SwiftUI

// MARK: - ListItemsView

private struct ListActions: TDSectionRowActions {
    var tapAction: ((Int) -> Void)?
    var swipeActions: ((Int, TDSectionRowActionType) -> Void)?
    var submitAction: ((String) -> Void)?
    var cancelAction: (() -> Void)?
    var moveAction: ((IndexSet, Int) -> Void)?
}

struct ListItemsView: View {
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
        .background(.backgroundWhite)
        .onAppear {
            store.send(.onAppear)
        }
        .disabled(
            store.state.viewState == .loading
        )
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
    }
}

// MARK: - Private

private extension ListItemsView {
    @ViewBuilder
    var itemsList: some View {
        ScrollViewReader { scrollView in
            SwiftUI.List {
                TDListSectionView(viewModel: store.state.viewModel.itemsSection,
                                  actions: listActions,
                                  newRowPlaceholder: Constants.Text.item)
                
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .onChange(of: store.state.viewState == .addingItem, {
                withAnimation {
                    scrollView.scrollTo(store.state.viewModel.itemsSection.rows.count - 1,
                                        anchor: .bottom)
                }
            })
        }
    }
    @ViewBuilder
    var newRowButton: some View {
        if store.state.viewState != .addingItem {
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        store.send(.didTapAddRowButton)
                    }
                }, label: {
                    Image.plusCircleFill
                        .resizable()
                        .frame(width: 48.0, height: 48.0)
                        .foregroundColor(.textBlack)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.backgroundWhite)
                        )
                })
                .foregroundColor(.textWhite)
            }
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
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
    
    var swipeActions: (Int, TDSectionRowActionType) -> Void {
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
