import Foundation

public struct UserList: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let documentId: String
    public var name: String
    public var done: Bool
    public var uid: [String]
    public let index: Int
    
    public init(documentId: String, name: String, done: Bool, uid: [String], index: Int) {
        self.documentId = documentId
        self.name = name
        self.done = done
        self.uid = uid
        self.index = index
    }
}
