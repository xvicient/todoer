import SwiftUI

struct ProductsView: View {
    @StateObject var viewModel: ProductsViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                ItemsView(viewModel: viewModel)
                TextField("Add product...",
                          text: $viewModel.productName)
                .textFieldStyle(BottomLineStyle() {
                    viewModel.addProduct()
                })
            }
            .task {
                viewModel.fetchProducts()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle(viewModel.listName)
    }
}

#Preview {
    ProductsView(viewModel: ProductsViewModel(
        listId: "", listName: "Test", productsRepository: ProductsRepository()))
}
