import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ItemDTO: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    public let name: String
    public var done: Bool
    public var index: Int
}
