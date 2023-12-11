import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProductsViewModel: ItemsViewModel {
    private var list: Todo
    let listName: String
    @Published var items: [any ItemModel] = []
    internal var options: (any ItemModel) -> [ItemOption] {
        {
            [$0.done ? .undone : .done,
             .delete]
        }
    }
    @Published var isLoading = false
    @Published var productName: String = ""
    private let productsRepository: ProductsRepositoryApi
    private let listsRepository: ListsRepositoryApi
    
    init(list: Todo,
         productsRepository: ProductsRepositoryApi = ProductsRepository(),
         listsRepository: ListsRepositoryApi = ListsRepository()) {
        self.list = list
        listName = list.name
        self.productsRepository = productsRepository
        self.listsRepository = listsRepository
    }
    
    func fetchProducts() {
        isLoading = true
        productsRepository.fetchProducts(listId: list.documentId) { [weak self] result in
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
                                      listId: list.documentId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.productName = ""
            case .failure:
                break
            }
        }
    }
    
    var onDidTapOption: ((any ItemModel, ItemOption) -> Void) {
        { [weak self] item, option in
            guard let self = self else { return }
            switch option {
            case .done, .undone:
                self.toggleProduct(item)
            case .delete:
                self.deleteProduct(item)
            default: break
            }
        }
    }
    
    private func toggleProduct(_ item: any ItemModel) {
        guard var product = item as? Product else { return }
        product.done.toggle()
        productsRepository.toggleProduct(product,
                                         listId: list.documentId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                list.done = self.items.allSatisfy({ $0.done })
                listsRepository.toggleList(list, completion: { _ in })
                break
            case .failure:
                break
            }
        }
    }
    
    private func deleteProduct(_ item: any ItemModel) {
        productsRepository.deleteProduct(item.documentId,
                                         listId: list.documentId)
    }
}

extension Product: ItemModel {}
