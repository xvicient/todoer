import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProductsViewModel: ItemsViewModel {
    private let listId: String
    let listName: String
    @Published var items: [any ItemModel] = []
    internal var options: [ItemOption] {
        [ItemOption(type: .doneUndone,
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
        self.listName = listName
        self.productsRepository = productsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts(listId: listId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let products):
                self?.items = products.sorted {
                    $0.dateCreated < $1.dateCreated
                }
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
    
    var finishProduct: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self,
                  var product = item as? ProductModel else { return }
            product.done.toggle()
            self.productsRepository.finishProduct(product,
                                                  listId: self.listId) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
        }
    }
    
    var deleteProduct: (any ItemModel) -> Void {
        { [weak self] item in
            guard let self = self,
                  let documentId = item.documentId else { return }
            self.productsRepository.deleteProduct(documentId,
                                                  listId: self.listId)
        }
    }
}

extension ProductModel: ItemModel {}
