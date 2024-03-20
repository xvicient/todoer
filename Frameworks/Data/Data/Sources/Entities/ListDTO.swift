import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ListDTO: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    public let name: String
    public let done: Bool
    public var uid: [String]
    public var index: Int
}
