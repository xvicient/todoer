import UIKit

protocol ProductsRepositoryApi {
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[ProductModel], Error>) -> Void
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
    func finishProduct(
        _ product: ProductModel,
        listId: String,
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
        completion: @escaping (Result<[ProductModel], Error>) -> Void
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
    
    func finishProduct(
        _ product: ProductModel,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.finishProduct(product.toDTO,
                                         listId: listId,
                                         completion: completion)
    }
}
