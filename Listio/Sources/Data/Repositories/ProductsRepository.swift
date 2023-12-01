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
    func toggleProduct(
        _ product: ProductModel,
        list: ListModel,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ProductsRepository: ProductsRepositoryApi {
    private let producstDataSource: ProductsDataSourceApi
    private let listsDataSource: ListsDataSourceApi
    
    init(producstDataSource: ProductsDataSourceApi = ProductsDataSource(),
         listsDataSource: ListsDataSourceApi = ListsDataSource()) {
        self.producstDataSource = producstDataSource
        self.listsDataSource = listsDataSource
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
    
    func toggleProduct(
        _ product: ProductModel,
        list: ListModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.toggleProduct(product.toDTO,
                                         listId: list.documentId) { [weak self] result in
            switch result {
            case .success:
                if !product.done && list.done {
                    var mutableList = list
                    mutableList.done.toggle()
                    self?.listsDataSource.toggleList(
                        mutableList.toDTO,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
}
