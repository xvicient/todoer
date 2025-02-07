import Foundation

public struct User: Identifiable, Equatable, Hashable, Sendable {
    public let id = UUID()
    public let documentId: String
    public var uid: String
    public var email: String?
    public var displayName: String?
    public var photoUrl: String?
    public var provider: String

    public init(
        documentId: String,
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        photoUrl: String? = nil,
        provider: String
    ) {
        self.documentId = documentId
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.provider = provider
    }
}
