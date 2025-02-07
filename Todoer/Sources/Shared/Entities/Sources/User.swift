import Foundation

/// A structure that represents a user in the application
/// Conforms to Identifiable for unique identification, Equatable for comparison,
/// Hashable for use in collections, and Sendable for concurrent operations
public struct User: Identifiable, Equatable, Hashable, Sendable {
    /// A unique identifier for the user
    public let id = UUID()
    /// The document identifier in the database
    public let documentId: String
    /// The unique identifier from the authentication provider
    public var uid: String
    /// The user's email address, if available
    public var email: String?
    /// The user's display name, if available
    public var displayName: String?
    /// The URL of the user's profile photo, if available
    public var photoUrl: String?
    /// The authentication provider used by the user (e.g., "google", "apple")
    public var provider: String
    
    /// Creates a new user instance
    /// - Parameters:
    ///   - documentId: The document identifier in the database
    ///   - uid: The unique identifier from the authentication provider
    ///   - email: The user's email address
    ///   - displayName: The user's display name
    ///   - photoUrl: The URL of the user's profile photo
    ///   - provider: The authentication provider used by the user
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
