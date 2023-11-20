import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class HomeViewModel: ObservableObject {
    @Published var products: [ProductDTO] = []
    @Published var isLoading = false
    @Published var productName: String = "Add product..."
    private let newProductHint = "Add product..."
    var hasProductHint: Bool {
        productName == newProductHint
    }
    private let productsRepository: ProductsRepositoryApi
    
    init(productsRepository: ProductsRepositoryApi) {
        self.productsRepository = productsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts { [weak self] result in
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
        guard !productName.isEmpty, !hasProductHint else { return }
        isLoading = true
        productsRepository.addProduct(with: productName) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.productName = ""
            case .failure:
                break
            }
        }
    }
    
    func deleteProduct(at indexSet: IndexSet) {
        guard let index = indexSet.first,
              let product = products[safe: index] else { return }
        productsRepository.deleteProduct(product)
    }
    
    func cleanProductHint() {
        guard hasProductHint else { return }
        productName = ""
    }
}
