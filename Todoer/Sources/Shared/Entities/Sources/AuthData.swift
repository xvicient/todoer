/// A structure that represents authentication data for a user
public struct AuthData {
    /// The unique identifier for the user
    public let uid: String
    /// The user's email address, if available
    public let email: String?
    /// The user's display name, if available
    public let displayName: String?
    /// The URL of the user's profile photo, if available
    public let photoUrl: String?
    /// Indicates whether this is an anonymous user
    public let isAnonymous: Bool
    
    /// Creates a new authentication data instance
    /// - Parameters:
    ///   - uid: The unique identifier for the user
    ///   - email: The user's email address
    ///   - displayName: The user's display name
    ///   - photoUrl: The URL of the user's profile photo
    ///   - isAnonymous: Whether this is an anonymous user
    public init(
        uid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        isAnonymous: Bool
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
    }
}
