import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var coordinator: Coordinator<AppRouter>
    
    var body: some View {
        ZStack {
            VStack {
                List(viewModel.lists) { list in
                    Button(action: {
                        coordinator.show(.products(list.id ?? "", list.name))
                    }, label: {
                        Text(list.name)
                    })
                }
                .task {
                    viewModel.fetchLists()
                }
                Form {
                    HStack {
                        TextField("Import list...", text: $viewModel.listId)
                        Button(action: {
                            viewModel.importList()
                        }, label: {
                            Label("", systemImage: "square.and.arrow.down")
                        })
                    }
                    HStack {
                        TextField("Add list...", text: $viewModel.listName)
                        Button(action: {
                            viewModel.addList()
                        }, label: {
                            Label("", systemImage: "plus.square")
                        })
                    }
                }
                .frame(maxHeight: 150)
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Your lists")
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
