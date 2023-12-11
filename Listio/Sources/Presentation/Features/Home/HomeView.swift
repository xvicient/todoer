import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        setupNavigationBar()
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                List {
                    invitationsSection
                    todosSection
                }
                VStack {
                    addTodoButton
                    addListTextField
                }
            }
            .task() {
                viewModel.fetchData()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("\(Constants.Title.welcome)")
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
            Button(
                action: {
                    print("User profile")
                }
            ) {
                AsyncImage(
                    url: URL(string: viewModel.userSelfPhoto),
                    content: {
                        $0.resizable().aspectRatio(contentMode: .fit)
                    }, placeholder: {
                        Image(systemName: Constants.Image.profilePlaceHolder)
                    })
                .frame(width: 30, height: 30)
                .cornerRadius(15.0)
            }
        }
    }
    
    @ViewBuilder
    var invitationsSection: some View {
        if !viewModel.invitations.isEmpty {
            Section(
                header:
                    Text(Constants.Title.invitations)
                    .foregroundColor(.buttonPrimary)
            ) {
                ForEach(viewModel.invitations) { invitation in
                    HStack {
                        VStack(alignment: .leading, content: {
                            Text("\(Constants.Title.from) \(invitation.listName)")
                            Text("\(Constants.Title.to) \(invitation.ownerName) (\(invitation.ownerEmail))")
                        })
                        Spacer()
                        Text("\(Constants.Title.pending)")
                    }
                    .background()
                    .onTapGesture {
                        viewModel.importList(listId: invitation.listId,
                                             invitationId: invitation.documentId)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var todosSection: some View {
        Section(
            header:
                Text(Constants.Title.todoos)
                .foregroundColor(.buttonPrimary)
        ) {
            ItemsView(viewModel: viewModel,
                      mainAction: itemViewMainAction,
                      optionsAction: itemViewOptionsAction)
            .alert("\(Constants.Title.shareTo)", isPresented: $viewModel.isShowingAlert) {
                TextField("\(Constants.Title.email)",
                          text: $viewModel.shareEmail)
                Button("\(Constants.Title.share)", role: .cancel) {
                    Task {
                        await viewModel.shareList()
                    }
                }
                Button("\(Constants.Title.cancel)", role: .destructive) {
                    viewModel.cancelShare()
                }
            }
        }
    }
    
    @ViewBuilder
    var addTodoButton: some View {
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
                    Spacer().frame(height: 10.0)
                    TextField(Constants.Title.addList,
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
    struct Constants {
        struct Title {
            static let welcome = "Welcome"
            static let invitations = "Invitations"
            static let todoos = "Todoos"
            static let from = "From:"
            static let to = "To:"
            static let pending = "Pending"
            static let shareTo = "Share to"
            static let email = "Email..."
            static let share = "Share"
            static let cancel = "Cancel"
            static let addList = "Add list..."
        }
        struct Image {
            static let profilePlaceHolder = "person.crop.circle"
            static let addButton = "plus.circle.fill"
            static let closeAddListButton = "xmark"
        }
    }
    
    func setupNavigationBar() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [
                .foregroundColor: UIColor(.buttonPrimary)
            ]
    }
    
    var itemViewMainAction: (any ItemModel) -> Void {
        {
            guard let list = $0 as? Todo else { return }
            coordinator.push(.products(list))
        }
    }
    
    var itemViewOptionsAction: (any ItemModel, ItemOption) -> Void {
        { item, option in
            viewModel.onDidTapOption(item, option)
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
