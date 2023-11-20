import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
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
                HStack {
                    TextEditor(text: $viewModel.productName)
                        .foregroundColor(viewModel.hasProductHint ? .gray : .primary)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.green, lineWidth: 2)
                        )
                        .cornerRadius(3)
                        .onTapGesture {
                            viewModel.cleanProductHint()
                        }
                    Button(action: {
                        viewModel.addProduct()
                        viewModel.cleanProductHint()
                    }, label: {
                        Label("Add", systemImage: "")
                    })
                }
                .padding(.horizontal, 12)
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
        productsRepository: ProductsRepository()))
}
