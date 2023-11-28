import SwiftUI

struct CreateListView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: CreateListViewModel
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    TextField("Add List...", text: $viewModel.listName)
                    Button(action: {
                        viewModel.createList()
                        coordinator.dismissSheet()
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
