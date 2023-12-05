import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.buttonPrimary)]
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                List {
                    if !viewModel.invitations.isEmpty {
                        Section(header: Text("Invitations")
                            .foregroundColor(.buttonPrimary)) {
                                ForEach(viewModel.invitations) { invitation in
                                    HStack {
                                        VStack(alignment: .leading, content: {
                                            Text("To: \(invitation.listName)")
                                            Text("From: \(invitation.ownerName) (\(invitation.ownerEmail))")
                                        })
                                        Spacer()
                                        Text("Pending")
                                    }
                                    .background()
                                    .onTapGesture {
                                        viewModel.importList(listId: invitation.listId,
                                                             invitationId: invitation.documentId)
                                    }
                                }
                            }
                    }
                    Section(header: Text("Todoos")
                        .foregroundColor(.buttonPrimary)) {
                        ItemsView(viewModel: viewModel,
                                  mainAction: {
                            guard let list = $0 as? ListModel else { return }
                            coordinator.push(.products(list))
                        },
                                  optionsAction: { item, option in
                            viewModel.onDidTapOption(item, option)
                        })
                        .alert("Share to", isPresented: $viewModel.isShowingAlert) {
                            TextField("Email...",
                                      text: $viewModel.shareEmail)
                            Button("Share", role: .cancel) {
                                Task {
                                    await viewModel.shareList()
                                }
                            }
                            Button("Cancel", role: .destructive) {
                                viewModel.cancelShare()
                            }
                        }
                    }
                }
                VStack {
                    Spacer()
                    Button(action: {
                        coordinator.present(sheet: .createList)
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 48.0, height: 48.0)
                    })
                    .foregroundColor(.buttonPrimary)
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
        .navigationTitle("Welcome ")
        .navigationBarItems(trailing:
                                Button(action: {
            // Agrega la lógica que desees al presionar el botón
            print("Botón presionado")
        }) {
            Image(systemName: "gear") // Utiliza el sistema de nombres de imágenes de SF Symbols
        }
        )
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
