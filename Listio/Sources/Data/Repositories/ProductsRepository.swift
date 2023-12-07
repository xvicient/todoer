import UIKit

protocol ProductsRepositoryApi {
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[Product], Error>) -> Void
    )
    func addProduct(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteProduct(
        _ documentId: String?,
        listId: String
    )
    func toggleProduct(
        _ product: Product,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func toogleAllProductsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ProductsRepository: ProductsRepositoryApi {
    private let producstDataSource: ProductsDataSourceApi
    
    init(producstDataSource: ProductsDataSourceApi = ProductsDataSource()) {
        self.producstDataSource = producstDataSource
    }
    
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[Product], Error>) -> Void
    ) {
        producstDataSource.fetchProducts(listId: listId) { result in
            switch result {
            case .success(let dto):
                completion(.success(
                    dto.map {
                        $0.toDomain
                    }
                ))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addProduct(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.addProduct(with: name,
                                      listId: listId,
                                      completion: completion)
    }
    
    func deleteProduct(
        _ documentId: String?,
        listId: String
    ) {
        producstDataSource.deleteProduct(documentId,
                                         listId: listId)
    }
    
    func toggleProduct(
        _ product: Product,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.toggleProduct(product.toDTO,
                                         listId: listId,
                                         completion: completion)
    }
    
    func toogleAllProductsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.toogleAllProductsBatch(listId: listId,
                                                  done: done,
                                                  completion: completion)
    }
}
