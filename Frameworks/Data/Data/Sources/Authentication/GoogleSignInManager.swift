import GoogleSignIn

public final class GoogleSignInManager {
	public static func handle(_ url: URL) -> Bool {
		GIDSignIn.sharedInstance.handle(url)
	}
}
