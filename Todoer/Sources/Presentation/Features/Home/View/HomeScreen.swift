import SwiftUI

// MARK: - HomeScreen

struct HomeScreen: View {
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
        .onAppear {
            store.send(.onViewAppear)
        }
        .disabled(
            store.state.viewState == .loading
        )
        .navigationBarItems(
            leading: navigationBarLeadingItems,
            trailing: navigationBarTrailingItems
        )
        .alert(item: alertBinding) {
            alert(for: $0)
        }
    }
}

// MARK: - ViewBuilders

private extension HomeScreen {
    @ViewBuilder
    var navigationBarTrailingItems: some View {
        TDOptionsMenu(sortHandler: { store.send(.didTapAutoSortLists) })
    }
    
    @ViewBuilder
    var navigationBarLeadingItems: some View {
        HStack {
            Spacer()
            Menu {
                Button(Constants.Text.about) {
                    store.send(.didTapAboutButton)
                }
                Button(Constants.Text.deleteAccount, role: .destructive) {
                    store.send(.didTapDeleteAccountButton)
                }
                Button(Constants.Text.logout) {
                    store.send(.didTapSignoutButton)
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
            HomeInvitationsView(
                invitations: store.state.viewModel.invitations,
                acceptHandler: { store.send(.didTapAcceptInvitation($0, $1)) },
                declineHandler: { store.send(.didTapDeclineInvitation($0))}
            )
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
                    TDNewRowView(
                        row: row,
                        onSubmit: { store.send(.didTapSubmitListButton($0)) },
                        onUpdate: { store.send(.didTapUpdateListButton(index, $0)) },
                        onCancelAdd: { store.send(.didTapCancelAddListButton) },
                        onCancelEdit: { store.send(.didTapCancelEditListButton(index)) }
                    )
                    .id(index)
                } else {
                    TDRowView(
                        row: TDRow(name: row.list.name,
                                   done: row.list.done,
                                   leadingActions: row.leadingActions,
                                   trailingActions: row.trailingActions,
                                   isEditing: row.isEditing),
                        onTap: { store.send(.didTapList(index)) },
                        onSwipe: { swipeActions(index, $0) }
                    )
                    .id(index)
                }
            }
                    .onMove(perform: moveList)
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
                        .frame(width: 42.0, height: 42.0)
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
}

// MARK: - Private

private extension HomeScreen {
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
    
    var alertBinding: Binding<Home.Reducer.AlertStyle?> {
        Binding(
            get: {
                guard case .alert(let data) = store.state.viewState else {
                    return nil
                }
                return data
            },
            set: { _ in }
        )
    }
    
    func alert(for style: Home.Reducer.AlertStyle) -> Alert {
        switch style {
        case let .error(message):
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: Text(message),
                dismissButton: .default(Text(Constants.Text.okButton)) {
                    store.send(.didTapDismissError)
                }
            )
        case .destructive:
            Alert(
                title: Text(""),
                message: Text(Constants.Text.deleteAccountConfirmation),
                primaryButton: .destructive(Text(Constants.Text.deleteButton)) {
                    store.send(.didTapConfirmDeleteAccount)
                },
                secondaryButton: .default(Text(Constants.Text.cancelButton)) {
                    store.send(.didTapDismissDeleteAccount)
                }
            )
        }
    }
}

// MARK: - Constants

private extension HomeScreen {
    struct Constants {
        struct Text {
            static let todos = "To-dos"
            static let logout = "Logout"
            static let about = "About"
            static let deleteAccount = "Delete account"
            static let deleteAccountConfirmation = "This action will delete your account and data. Are you sure?"
            static let errorTitle = "Error"
            static let okButton = "Ok"
            static let deleteButton = "Delete"
            static let cancelButton = "Cancel"
        }
    }
}

#Preview {
    Home.Builder.makeHome(coordinator: Coordinator())
}
