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
            content
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
        TDRowOptions(sortHandler: { store.send(.didTapAutoSortLists) })
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
    var content: some View {
        ScrollView {
            invitations
            listsSection
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    var invitations: some View {
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
        VStack(alignment: .leading) {
            Text(Constants.Text.todos)
                .font(.title3)
                .foregroundColor(.textBlack)
            
            ForEach(Array(store.state.viewModel.lists.enumerated()),
                    id: \.element.id) { index, row in
                if row.isEditing {
                    newRow(row, index: index)
                        .id(row.id)
                } else {
                    TDRow(row: row,
                          tapHandler: { store.send(.didTapList(index)) },
                          swipeHandler: { swipeActions(index, $0) }
                    )
                }
            }
                    .onMove(perform: moveList)
        }
        .padding(.top, 16)
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
                hideKeyboard()
                if row.list.name.isEmpty {
                    store.send(.didTapCancelAddListButton)
                } else {
                    store.send(.didTapCancelEditListButton(index))
                }
            }) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.buttonBlack)
            }
            .buttonStyle(.borderless)
        }
        .frame(height: 40)
        .onAppear {
            isNewRowFocused = true
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
    var swipeActions: (Int, TDSwipeActionOption) -> Void {
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
            static let list = "List..."
            static let logout = "Logout"
            static let about = "About"
            static let autoSort = "To-do first"
            static let deleteAccount = "Delete account"
            static let deleteAccountConfirmation = "This action will delete your account and data. Are you sure?"
            static let errorTitle = "Error"
            static let okButton = "Ok"
            static let deleteButton = "Delete"
            static let cancelButton = "Cancel"
        }
        struct Image {
            static let launchScreen = "LaunchScreen"
        }
    }
}

#Preview {
    Home.Builder.makeHome(coordinator: Coordinator())
}
