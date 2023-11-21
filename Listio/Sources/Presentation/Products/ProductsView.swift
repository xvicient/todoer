import SwiftUI

struct ProductsView: View {
    @StateObject var viewModel: ProductsViewModel
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(viewModel.products, id: \.self) {
                        Text($0.name)
                    }
                    .onDelete {
                        viewModel.deleteProduct(at: $0)
                    }
                }
                .task {
                    viewModel.fetchProducts()
                }
                Form {
                    HStack {
                        TextField("Add product...", text: $viewModel.productName)
                        Button(action: {
                            viewModel.addProduct()
                        }, label: {
                            Label("", systemImage: "plus.square")
                        })
                    }
                }
                .frame(maxHeight: 75)
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
