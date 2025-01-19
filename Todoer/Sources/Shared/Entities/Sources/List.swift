import Foundation

public struct UserList: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let documentId: String
    public var name: String
    public var done: Bool
    public var uid: [String]
    public let index: Int
    
    public init(
        id: UUID,
        documentId: String,
        name: String,
        done: Bool,
        uid: [String],
        index: Int
    ) {
        self.id = id
        self.documentId = documentId
        self.name = name
        self.done = done
        self.uid = uid
        self.index = index
    }
}
