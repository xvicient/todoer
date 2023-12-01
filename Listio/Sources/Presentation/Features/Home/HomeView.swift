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
                ItemsView(viewModel: viewModel) {
                    guard let list = $0 as? ListModel else { return }
                    coordinator.push(.products(list))
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
