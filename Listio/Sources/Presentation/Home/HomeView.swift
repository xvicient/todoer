import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                List(viewModel.lists, id: \.self) {
                    NavigationLink($0.name, value: $0)
                }
                .navigationDestination(for: ListDTO.self) {
                    viewModel.productsView(listId: $0.id,
                                           listName: $0.name)
                }
                .navigationTitle("Your lists")
                .task {
                    viewModel.fetchLists()
                }
                Form {
                    HStack {
                        TextField("Import list...", text: $viewModel.listName)
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
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
