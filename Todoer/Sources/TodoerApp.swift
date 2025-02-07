import SwiftUI
import FirebaseCore
import GoogleSignIn
import Coordinator
import CoordinatorContract

/// `AppDelegate` is responsible for handling application lifecycle events and third-party service configurations
/// This class implements `UIApplicationDelegate` to manage app-level functionality
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Configures Firebase when the application launches
    /// - Parameters:
    ///   - application: The singleton app object
    ///   - launchOptions: A dictionary indicating the reason the app was launched
    /// - Returns: `true` if the app was configured successfully
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    /// Handles URL schemes for Google Sign-In
    /// - Parameters:
    ///   - app: The singleton app object
    ///   - url: The URL that was passed to the app
    ///   - options: A dictionary of URL handling options
    /// - Returns: `true` if the URL was handled successfully
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

/// `TodoerApp` is the main entry point of the application
/// It sets up the app delegate and configures the main window scene
@main
struct TodoerApp: App {
    /// The app delegate instance responsible for handling application lifecycle events
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// The main scene of the application
    /// - Returns: A window group containing the coordinator view
    var body: some Scene {
        WindowGroup {
            CoordinatorView(featureProvider: FeatureProvider())
        }
    }
}
