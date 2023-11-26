import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var coordinator: Coordinator<AppRouter>
    
    var action: (String?, String) -> Void {
        { id, name in
            guard let id = id else {
                return
            }
            coordinator.show(.products(id, name))
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                ItemsView(viewModel: viewModel) { id, name in
                    coordinator.show(.products(id ?? "", name))
                }
                VStack {
                    Spacer()
                    Button(action: {
                        // Show add list
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 48.0, height: 48.0)
                    })
                    .foregroundColor(.buttonPrimary)
                }
            }
            .task() {
                viewModel.fetchLists()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Your todoos")
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
