import SwiftUI

// MARK: - HomeView

private struct ListActions: TDSectionRowActions {
    var tapAction: ((Int) -> Void)?
    var swipeActions: ((Int, TDSectionRowActionType) -> Void)?
    var submitAction: ((String) -> Void)?
    var cancelAction: (() -> Void)?
}

struct HomeView: View {
    @ObservedObject private var store: Store<Home.Reducer>
    
    init(store: Store<Home.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.backgroundPrimary, .backgroundSecondary]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        .overlay(
            ZStack {
                ScrollViewReader { scrollView in
                    SwiftUI.List {
                        invitationsSection
                        listsSection
                    }
                    .scrollContentBackground(.hidden)
                    .onChange(of: store.state.viewState == .addingList, {
                        withAnimation {
                            scrollView.scrollTo(store.state.viewModel.listsSection.rows.count - 1,
                                                anchor: .bottom)
                        }
                    })
                }
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
                trailing: navigationBarItems
            )
        )
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
            } label: {
                AsyncImage(
                    url: URL(string: store.state.viewModel.photoUrl),
                    content: {
                        $0.resizable().aspectRatio(contentMode: .fit)
                    }, placeholder: {
                        Image(systemName: Constants.Image.profilePlaceHolder)
                            .tint(.buttonPrimary)
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
    var invitationsSection: some View {
        if !store.state.viewModel.invitations.isEmpty {
            Section(
                header:
                    Text(Constants.Text.invitations)
                    .foregroundColor(.textWhite)
            ) {
                ForEach(store.state.viewModel.invitations) { invitation in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(invitation.ownerName)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text("(\(invitation.ownerEmail))")
                                .font(.system(size: 14, weight: .light))
                                .padding(.bottom, 8)
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
                    .background()
                }
            }
        }
    }
    
    @ViewBuilder
    var listsSection: some View {
        TDListSectionView(viewModel: store.state.viewModel.listsSection,
                          actions: listActions,
                          sectionTitle: Constants.Text.todoos,
                          newRowPlaceholder: Constants.Text.list)
    }
    
    @ViewBuilder
    var newRowButton: some View {
        if store.state.viewState != .addingList {
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
                .foregroundColor(.buttonAccent)
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

private extension HomeView {
    var listActions: ListActions {
        ListActions(tapAction: tapAction,
                    swipeActions: swipeActions,
                    submitAction: submitAction,
                    cancelAction: cancelAction)
    }
    
    var tapAction: (Int) -> Void {
        { store.send(.didTapList($0)) }
    }
    
    var swipeActions: (Int, TDSectionRowActionType) -> Void {
        { index, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleListButton(index))
            case .delete:
                store.send(.didTapDeleteListButton(index))
            case .share:
                store.send(.didTapShareListButton(index))
            }
        }
    }
    
    var submitAction: (String) -> Void {
        { store.send(.didTapSubmitListButton($0)) }
    }
    
    var cancelAction: () -> Void {
        { store.send(.didTapCancelAddRowButton) }
    }
}

// MARK: - Constants

private extension HomeView {
    struct Constants {
        struct Text {
            static let title = "Todoo"
            static let invitations = "Invitations"
            static let todoos = "Todoos"
            static let wantsToShare = "Wants to share: "
            static let accept = "Accept"
            static let decline = "Decline"
            static let list = "List..."
            static let logout = "Logout"
        }
        struct Image {
            static let launchScreen = "LaunchScreen"
            static let profilePlaceHolder = "person.crop.circle"
            static let addButton = "plus.circle.fill"
            static let closeAddListButton = "xmark"
        }
    }
}

#Preview {
    Home.Builder.makeHome(coordinator: Coordinator())
}
