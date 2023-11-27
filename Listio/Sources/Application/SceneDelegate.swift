import SwiftUI

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    private var coordinator: Coordinator<AppRouter> = {
        do {
            _ = try AuthenticationService().getAuthenticatedUser()
            return .init(startingRoute: .home)
        } catch {
            return .init(startingRoute: .authentication)
        }
    }()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = coordinator.navigationController
        window?.makeKeyAndVisible()
        coordinator.start()
    }
}
