import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProductsDataSourceApi {
    func fetchProducts(by uuid: String, completion: @escaping (Result<[ProductDTO], Error>) -> Void)
    func addProduct(_ product: ProductDTO, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteProduct(_ product: ProductDTO)
}

final class ProductsDataSource: ProductsDataSourceApi {
    private let collection = Firestore.firestore().collection("products")
    
    func fetchProducts(by uuid: String, completion: @escaping (Result<[ProductDTO], Error>) -> Void) {
        collection
            .whereField("uuid", isEqualTo: uuid)
            .addSnapshotListener { query, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let products = query?.documents
                .compactMap { try? $0.data(as: ProductDTO.self) }
            ?? []
            completion(.success(products))
        }
    }
    
    func addProduct(_ product: ProductDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try collection.addDocument(from: product)
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteProduct(_ product: ProductDTO) {
        guard let id = product.id else { return }
        collection.document(id).delete()
    }
}
