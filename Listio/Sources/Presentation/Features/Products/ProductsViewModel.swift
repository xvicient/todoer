import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProductsViewModel: ItemsViewModel {
    private let listId: String
    @Published var items: [ItemModel] = []
    internal var options: [ItemOption] {
        [ItemOption(type: .done,
                    action: finishProduct),
         ItemOption(type: .delete,
                    action: deleteProduct)]
    }
    @Published var isLoading = false
    @Published var productName: String = ""
    private let productsRepository: ProductsRepositoryApi
    
    init(listId: String,
         listName: String,
         productsRepository: ProductsRepositoryApi) {
        self.listId = listId
        self.productsRepository = productsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts(listId: listId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let products):
                self?.items = products
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
              let product = items[safe: index] as? ProductDTO else { return }
        productsRepository.deleteProduct(product,
                                         listId: listId)
    }
    
    var finishProduct: (String?) -> Void {
        { id in
            
        }
    }
    
    var deleteProduct: (String?) -> Void {
        { id in
            
        }
    }
}

extension ProductDTO: ItemModel {}
