import UIKit

enum ProductsRepositoryError: Error {
    case missingUuid
}

protocol ProductsRepositoryApi {
    func fetchProducts(completion: @escaping (Result<[ProductDTO], Error>) -> Void)
    func addProduct(with name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(_ product: ProductDTO)
}

final class ProductsRepository: ProductsRepositoryApi {
    private let producstDataSource: ProductsDataSourceApi
    private let uuid = UIDevice.current.identifierForVendor?.uuidString
    
    init(producstDataSource: ProductsDataSourceApi = ProductsDataSource()) {
        self.producstDataSource = producstDataSource
    }
    
    func fetchProducts(completion: @escaping (Result<[ProductDTO], Error>) -> Void) {
        guard let uuid = uuid else {
            completion(.failure(ProductsRepositoryError.missingUuid))
            return
        }
        producstDataSource.fetchProducts(by: uuid, completion: completion)
    }
    
    func addProduct(with name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = uuid else {
            completion(.failure(ProductsRepositoryError.missingUuid))
            return
        }
        producstDataSource.addProduct(ProductDTO(name: name, uuid: uuid),
                                      completion: completion)
    }
    
    func deleteProduct(_ product: ProductDTO) {
        producstDataSource.deleteProduct(product)
    }
}
