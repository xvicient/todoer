import SwiftUI

struct ListItemsView: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    @FocusState private var isNewRowFocused: Bool
    @State private var newRowText = ""
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

private extension ListItemsView {
    @ViewBuilder
    var itemsList: some View {
        ScrollViewReader { scrollView in
            SwiftUI.List {
                Section(
                    header:
                        Text(listName)
                        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .foregroundColor(.textBlack)
                ) {
                    ForEach(Array(store.state.viewModel.items.enumerated()),
                            id: \.element.id) { index, row in
                        if row.isEditing {
                            newRow(row, index: index)
                                .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .id(row.id)
                        } else {
                            itemRow(row, index: index)
                                .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .id(row.id)
                        }
                    }
                            .onMove(perform: moveItem)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .onChange(of: store.state.viewState == .addingItem, {
                withAnimation {
                    scrollView.scrollTo(store.state.viewModel.items.count - 1,
                                        anchor: .bottom)
                }
            })
        }
    }
    
    @ViewBuilder
    func itemRow(
        _ row: ListItems.Reducer.ItemRow,
        index: Int
    ) -> some View {
        Group {
            HStack {
                (row.item.done ? Image.largecircleFillCircle : Image.circle)
                    .foregroundColor(.buttonBlack)
                Button(action: {}) {
                    Text(row.item.name)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .strikethrough(row.item.done)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .foregroundColor(.textBlack)
            }
            .frame(minHeight: 40)
        }
        .swipeActions(edge: .leading) {
            swipeActions(
                row.leadingActions,
                index: index
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(
                row.trailingActions,
                index: index
            )
        }
    }
    
    @ViewBuilder
    func newRow(
        _ row: ListItems.Reducer.ItemRow,
        index: Int) -> some View {
            HStack {
                Image.circle
                    .foregroundColor(.buttonBlack)
                TextField(Constants.Text.item, text: $newRowText)
                    .foregroundColor(.textBlack)
                    .focused($isNewRowFocused)
                    .onAppear {
                        newRowText = row.item.name
                    }
                    .onSubmit {
                        hideKeyboard()
                        if row.item.name.isEmpty {
                            store.send(.didTapSubmitItemButton($newRowText.wrappedValue))
                        } else {
                            store.send(.didTapUpdateItemButton(index, $newRowText.wrappedValue))
                        }
                    }
                    .submitLabel(.done)
                Button(action: {
                    withAnimation {
                        if row.item.name.isEmpty {
                            store.send(.didTapCancelAddItemButton)
                        } else {
                            store.send(.didTapCancelEditItemButton(index))
                        }
                    }
                }) {
                    Image.xmark
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.buttonBlack)
                }
            }
            .frame(height: 40)
            .onAppear {
                isNewRowFocused = true
            }
        }
    
    @ViewBuilder
    func swipeActions(
        _ actions: [TDSwipeAction],
        index: Int
    ) -> some View {
        ForEach(actions,
                id: \.id) { option in
            Button {
                withAnimation {
                    swipeActions(index, option)
                }
            } label: {
                option.icon
            }
            .tint(option.tint)
        }
    }
    
    @ViewBuilder
    var newRowButton: some View {
        if store.state.viewState != .addingItem &&
            store.state.viewState != .editingItem {
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        store.send(.didTapAddItemButton)
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
    
    @ViewBuilder
    var alertErrorMessage: Text? {
        if case let .error(error) = store.state.viewState {
            Text(error)
        }
    }
}

// MARK: - Private

private extension ListItemsView {
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
                { if case .error = store.state.viewState { return true } else { return false } }()
            },
            set: { _ in }
        )
    }
}

// MARK: - Constants

private extension ListItemsView {
    struct Constants {
        struct Text {
            static let item = "Item..."
            static let errorTitle = "Error"
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
            index: 1)
    )
}
