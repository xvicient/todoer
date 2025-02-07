import Foundation

public struct Item: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let documentId: String
    public var name: String
    public var done: Bool
    public var index: Int

    public init(
        id: UUID,
        documentId: String,
        name: String,
        done: Bool,
        index: Int
    ) {
        self.id = id
        self.documentId = documentId
        self.name = name
        self.done = done
        self.index = index
    }
}
