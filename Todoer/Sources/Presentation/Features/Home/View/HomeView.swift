import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @ObservedObject private var store: Store<Home.Reducer>
    @FocusState private var isNewRowFocused: Bool
    @State private var newRowText = ""
    
    init(store: Store<Home.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            lists
            newRowButton
            loadingView
        }
        .background(.backgroundWhite)
        .onAppear {
            store.send(.onViewAppear)
        }
        .disabled(
            store.state.viewState == .loading
        )
        .navigationBarItems(
            trailing: navigationBarItems
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

// MARK: - ViewBuilders

private extension HomeView {
    @ViewBuilder
    var navigationBarItems: some View {
        HStack {
            Spacer()
            Menu {
                Button(Constants.Text.logout) {
                    store.send(.didTapSignoutButton)
                }
                Button(Constants.Text.about) {
                    store.send(.didTapAboutButton)
                }
            } label: {
                AsyncImage(
                    url: URL(string: store.state.viewModel.photoUrl),
                    content: {
                        $0.resizable().aspectRatio(contentMode: .fit)
                    }, placeholder: {
                        Image.personCropCircle
                            .tint(.buttonBlack)
                    })
                .frame(width: 30, height: 30)
                .cornerRadius(15.0)
            }
        }
        .onAppear {
            store.send(.onProfilePhotoAppear)
        }
    }
    
    @ViewBuilder
    var lists: some View {
        ScrollViewReader { scrollView in
            SwiftUI.List {
                invitationsSection
                listsSection
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .onChange(of: store.state.viewState == .addingList, {
                withAnimation {
                    scrollView.scrollTo(store.state.viewModel.lists.count - 1,
                                        anchor: .bottom)
                }
            })
        }
    }
    
    @ViewBuilder
    var invitationsSection: some View {
        if !store.state.viewModel.invitations.isEmpty {
            Section(
                header:
                    Text(Constants.Text.invitations)
                    .foregroundColor(.textBlack)
                    .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
            ) {
                ForEach(store.state.viewModel.invitations) { invitation in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(invitation.ownerName)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textBlack)
                            if !invitation.ownerEmail.isEmpty {
                                Text("(\(invitation.ownerEmail))")
                                    .font(.system(size: 14, weight: .light))
                                    .padding(.bottom, 8)
                            }
                            Text("\(Constants.Text.wantsToShare)")
                                .font(.system(size: 14))
                            Text("\(invitation.listName)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        VStack {
                            TDButton(title: "\(Constants.Text.accept)",
                                     style: .primary,
                                     size: .custom(with: 100, height: 32)) {
                                store.send(.didTapAcceptInvitation(invitation.listId,
                                                                   invitation.documentId))
                            }
                            TDButton(title: "\(Constants.Text.decline)",
                                     style: .destructive,
                                     size: .custom(with: 100, height: 32)) {
                                store.send(.didTapDeclineInvitation(invitation.documentId))
                            }
                        }
                    }
                    .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .background()
                }
            }
        }
    }
    
    @ViewBuilder
    var listsSection: some View {
        Section(header:
                    Text(Constants.Text.todos)
            .foregroundColor(.textBlack)
            .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
        ) {
            ForEach(Array(store.state.viewModel.lists.enumerated()),
                    id: \.element.id) { index, row in
                if row.isEditing {
                    newRow(row, index: index)
                        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .id(row.id)
                } else {
                    listRow(row, index: index)
                        .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .id(row.id)
                }
            }
                    .onMove(perform: moveList)
        }
    }
    
    @ViewBuilder
    func listRow(
        _ row: Home.Reducer.ListRow,
        index: Int
    ) -> some View {
        Group {
            HStack {
                (row.list.done ? Image.largecircleFillCircle : Image.circle)
                    .foregroundColor(.buttonBlack)
                Button(action: {
                    store.send(.didTapList(index))
                }) {
                    Text(row.list.name)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .strikethrough(row.list.done)
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
        _ row: Home.Reducer.ListRow,
        index: Int
    ) -> some View {
        HStack {
            (row.list.done ? Image.largecircleFillCircle : Image.circle)
                .foregroundColor(.buttonBlack)
            TextField(Constants.Text.list, text: $newRowText)
                .foregroundColor(.textBlack)
                .focused($isNewRowFocused)
                .onAppear {
                    newRowText = row.list.name
                }
                .onSubmit {
                    hideKeyboard()
                    if row.list.name.isEmpty {
                        store.send(.didTapSubmitListButton($newRowText.wrappedValue))
                    } else {
                        store.send(.didTapUpdateListButton(index, $newRowText.wrappedValue))
                    }
                }
                .submitLabel(.done)
            Button(action: {
                if row.list.name.isEmpty {
                    store.send(.didTapCancelAddListButton)
                } else {
                    store.send(.didTapCancelEditListButton)
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
        if store.state.viewState != .addingList &&
            store.state.viewState != .editingList {
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

private extension HomeView {
    var swipeActions: (Int, TDSwipeAction) -> Void {
        { index, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleListButton(index))
            case .delete:
                store.send(.didTapDeleteListButton(index))
            case .share:
                store.send(.didTapShareListButton(index))
            case .edit:
                store.send(.didTapEditListButton(index))
            }
        }
    }
    
    func moveList(fromOffset: IndexSet, toOffset: Int) {
        store.send(.didSortLists(fromOffset, toOffset))
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

private extension HomeView {
    struct Constants {
        struct Text {
            static let invitations = "Invitations"
            static let todos = "To-dos"
            static let wantsToShare = "Wants to share: "
            static let accept = "Accept"
            static let decline = "Decline"
            static let list = "List..."
            static let logout = "Logout"
            static let about = "About"
            static let errorTitle = "Error"
            static let errorOkButton = "Ok"
        }
        struct Image {
            static let launchScreen = "LaunchScreen"
        }
    }
}

#Preview {
    Home.Builder.makeHome(coordinator: Coordinator())
}
