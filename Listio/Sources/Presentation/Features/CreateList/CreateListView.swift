import SwiftUI

struct CreateListView: View {
    @EnvironmentObject var coordinator: Coordinator<AppRouter>
    @StateObject var viewModel: CreateListViewModel
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    TextField("Add List...", text: $viewModel.listName)
                    Button(action: {
                        viewModel.createList()
                        coordinator.popToRoot()
                    }, label: {
                        Image(systemName: "plus.square")
                    })
                }
            }
        }
    }
}

#Preview {
    CreateListView(viewModel: CreateListViewModel(listsRepository: ListsRepository()))
}
