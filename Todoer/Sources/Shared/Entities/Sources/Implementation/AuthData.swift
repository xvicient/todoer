public struct AuthData {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let photoUrl: String?
    public let isAnonymous: Bool

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
