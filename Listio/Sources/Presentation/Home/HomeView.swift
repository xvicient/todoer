import SwiftUI

// MARK: - HomeView

private struct ListActions: TDSectionRowActions {
    var tapAction: ((any TDSectionRow) -> Void)?
    var swipeActions: ((Int, TDSectionRowActionType) -> Void)?
    var submitAction: ((String) -> Void)?
    var cancelAction: (() -> Void)?
}

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @ObservedObject private var store: Store<Home.Reducer>
    
    init(viewModel: HomeViewModel,
         store: Store<Home.Reducer>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.store = store
        setupNavigationBar()
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                SwiftUI.List {
                    invitationsSection
                    todosSection
                }
                VStack {
                    addListButton
                    addListTextField
                }
            }
            .onAppear {
                store.send(.onViewAppear)
            }
            .disabled(store.state.viewState == .loading)
            if store.state.viewState == .loading {
                ProgressView()
            }
        }
        .navigationTitle("\(Constants.Text.title)")
        .navigationBarItems(
            trailing: navigationBarItems
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
                    viewModel.signOut()
                    coordinator.loggOut()
                }
            } label: {
                AsyncImage(
                    url: URL(string: viewModel.userSelfPhoto),
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
                    .foregroundColor(.buttonPrimary)
            ) {
                ForEach(store.state.viewModel.invitations) { invitation in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(invitation.ownerName)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.buttonPrimary)
                            Text("(\(invitation.ownerEmail))")
                                .font(.system(size: 14, weight: .light))
                                .padding(.bottom, 8)
                            Text("\(Constants.Text.wantsToShare)")
                                .font(.system(size: 14))
                            Text("\(invitation.listName)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(UIColor.darkGray))
                        }
                        Spacer()
                        VStack {
                            TDButton(title: "\(Constants.Text.accept)",
                                     style: .primary,
                                     size: .custom(with: 100, height: 32)) {
                                viewModel.importList(listId: invitation.listId,
                                                     invitationId: invitation.documentId)
                            }
                            TDButton(title: "\(Constants.Text.decline)",
                                     style: .destructive,
                                     size: .custom(with: 100, height: 32)) {
                                viewModel.deleteInvitation(invitationId: invitation.documentId)
                            }
                        }
                    }
                    .background()
                }
            }
        }
    }
    
    @ViewBuilder
    var todosSection: some View {
        TDListSectionView(viewModel: store.state.viewModel.listsSection,
                          actions: listActions,
                          sectionTitle: Constants.Text.todoos)
    }
    
    @ViewBuilder
    var addListButton: some View {
        if viewModel.isShowingAddButton {
            Spacer()
            Button(action: {
                viewModel.isShowingAddButton = false
                withAnimation(.easeOut(duration: 0.75)) {
                    viewModel.isShowingAddTextField = true
                }
            }, label: {
                Image(systemName: Constants.Image.addButton)
                    .resizable()
                    .frame(width: 48.0, height: 48.0)
            })
            .foregroundColor(.buttonPrimary)
        }
    }
    
    @ViewBuilder
    var addListTextField: some View {
        if viewModel.isShowingAddTextField {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.75)) {
                        viewModel.isShowingAddTextField = false
                    } completion: {
                        viewModel.isShowingAddButton = true
                    }
                }, label: {
                    Image("")
                        .resizable()
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity)
                        .ignoresSafeArea()
                })
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.75)) {
                                viewModel.isShowingAddTextField = false
                            } completion: {
                                viewModel.isShowingAddButton = true
                            }
                        },
                               label: {
                            Image(systemName: Constants.Image.closeAddListButton)
                                .resizable()
                                .frame(width: 16.0, height: 16.0)
                        })
                        .foregroundColor(.buttonPrimary)
                        .padding([.top, .trailing], 24.0)
                    }
                    TextField(Constants.Text.addList,
                              text: $viewModel.listName)
                    .textFieldStyle(BottomLineStyle() {
                        viewModel.createList()
                    })
                    .background(.white)
                }
                .background(
                    Color.white
                        .shadow(color: .buttonPrimary, radius: 6, x: 0, y: 10)
                        .mask(Rectangle().padding(.top, -25))
                )
            }
            .transition(.move(edge: .bottom))
        }
    }
}

// MARK: - Private

private extension HomeView {
    func setupNavigationBar() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [
                .foregroundColor: UIColor(.buttonPrimary)
            ]
    }
    
    var listActions: ListActions {
        ListActions(tapAction: tapAction,
                    swipeActions: swipeActions)
    }
    
    var tapAction: (any TDSectionRow) -> Void {
        {
            guard let list = $0 as? List else { return }
            coordinator.push(.products(list))
        }
    }
    
    var swipeActions: (Int, TDSectionRowActionType) -> Void {
        { index, option in
            if case .share = option {
                guard let list = viewModel.rows[index] as? List else {
                    return
                }
                coordinator.present(sheet: .shareList(list))
            } else {
                viewModel.onDidTapOption(index, option)
            }
        }
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
            static let addList = "List name..."
            static let logout = "Logout"
        }
        struct Image {
            static let profilePlaceHolder = "person.crop.circle"
            static let addButton = "plus.circle.fill"
            static let closeAddListButton = "xmark"
        }
    }
}

#Preview {
    Home.Builder.makeHome(coordinator: Coordinator())
}
