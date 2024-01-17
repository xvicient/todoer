import FirebaseAuth

struct AuthDataDTO {
    let uid: String
    let email: String?
    let displayName: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
        self.displayName = user.displayName
    }
}
