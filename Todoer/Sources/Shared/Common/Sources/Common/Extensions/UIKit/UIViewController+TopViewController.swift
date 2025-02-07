import UIKit

/// Utility functions for UIKit-related operations
public struct Utils {
    /// Finds the topmost view controller in the view hierarchy
    /// - Parameter controller: Optional starting view controller. If nil, starts from the root view controller
    /// - Returns: The topmost view controller, or nil if none found
    /// This method traverses the view controller hierarchy considering:
    /// - Navigation controllers (returns their visible view controller)
    /// - Tab bar controllers (returns their selected view controller)
    /// - Presented view controllers (returns the presented controller)
    @MainActor
    public static func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last?.rootViewController

        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
