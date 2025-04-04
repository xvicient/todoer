import Foundation

public struct User: Identifiable, Equatable, Hashable, Sendable {
    private enum Errors: Error {
        case invalidId
    }
    public let id: String
    public var uid: String
    public var email: String?
    public var displayName: String?
    public var photoUrl: String?
    public var provider: String

    public init(
        id: String?,
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        photoUrl: String? = nil,
        provider: String
    ) throws {
        guard let id else {
            throw Errors.invalidId
        }
        self.id = id
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.provider = provider
    }
}
