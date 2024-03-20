import Data
import SwiftUI
import Presentation

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
        FirebaseManager.configure()
		return true
	}

	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]
	) -> Bool {
        GoogleSignInManager.handle(url)
	}
}

@main
struct TodoerApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

	var body: some Scene {
		WindowGroup {
			CoordinatorView()
		}
	}
}
