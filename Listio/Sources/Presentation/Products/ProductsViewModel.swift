import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsViewModel: ObservableObject {
    private let listId: String
    let listName: String
    @Published var products: [ProductDTO] = []
    @Published var isLoading = false
    @Published var productName: String = ""
    private let productsRepository: ProductsRepositoryApi
    
    init(listId: String,
         listName: String,
         productsRepository: ProductsRepositoryApi) {
        self.listId = listId
        self.listName = listName
        self.productsRepository = productsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts(listId: listId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let products):
                self?.products = products
            case .failure:
                break
            }
        }
    }
    
    func addProduct() {
        guard !productName.isEmpty else { return }
        isLoading = true
        productsRepository.addProduct(with: productName,
                                      listId: listId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.productName = ""
            case .failure:
                break
            }
        }
    }
    
    func deleteProduct(
        at indexSet: IndexSet
    ) {
        guard let index = indexSet.first,
              let product = products[safe: index] else { return }
        productsRepository.deleteProduct(product,
                                         listId: listId)
    }
}
