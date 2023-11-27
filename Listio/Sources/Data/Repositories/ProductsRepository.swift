import UIKit

protocol ProductsRepositoryApi {
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[ProductDTO], Error>) -> Void
    )
    func addProduct(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteProduct(
        _ product: ProductDTO,
        listId: String
    )
}

final class ProductsRepository: ProductsRepositoryApi {
    private let producstDataSource: ProductsDataSourceApi
    
    init(producstDataSource: ProductsDataSourceApi = ProductsDataSource()) {
        self.producstDataSource = producstDataSource
    }
    
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[ProductDTO], Error>) -> Void
    ) {
        producstDataSource.fetchProducts(listId: listId, 
                                         completion: completion)
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
        _ product: ProductDTO,
        listId: String
    ) {
        producstDataSource.deleteProduct(product,
                                         listId: listId)
    }
}
