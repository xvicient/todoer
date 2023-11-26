import SwiftUI

struct ProductsView: View {
    @StateObject var viewModel: ProductsViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                ItemsView(viewModel: viewModel)
                Form {
                    HStack {
                        TextField("Add product...", text: $viewModel.productName)
                        Button(action: {
                            viewModel.addProduct()
                        }, label: {
                            Image(systemName: "plus.square")
                        })
                    }
                }
                .frame(maxHeight: 75)
            }
            .task {
                viewModel.fetchProducts()
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    ProductsView(viewModel: ProductsViewModel(
        listId: "", listName: "Test", productsRepository: ProductsRepository()))
}
