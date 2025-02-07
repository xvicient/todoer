import SwiftUI
import Data
import Entities

/// Represents different pages in the application navigation stack
public enum Page: Hashable, Identifiable {
    /// Authentication/login page
    case authentication
    /// Home screen/dashboard
    case home
    /// List items screen showing contents of a specific user list
    case listItems(UserList)
    /// About screen with app information
    case about
    /// App menu screen
    case menu

    /// Unique identifier for the page
    public var id: Self { self }
}

/// Represents different sheets that can be presented modally
public enum Sheet: Hashable, Identifiable {
    /// Sheet for sharing a user list
    case shareList(UserList)

    /// Unique identifier for the sheet
    public var id: Self { self }
}

/// Represents different full-screen covers that can be presented
public enum FullScreenCover: Hashable, Identifiable {
    /// Full-screen home view
    case home

    /// Unique identifier for the full-screen cover
    public var id: Self { self }
}

/// Protocol defining the navigation and flow control API for the application
/// Must be used on the main actor as it deals with UI navigation
@MainActor
public protocol CoordinatorApi {
    /// Indicates whether a user is currently logged in
    var isUserLogged: Bool { get }
    
    /// Logs out the current user
    func loggOut()
    
    /// Logs in a user
    func loggIn()
    
    /// Pushes a new page onto the navigation stack
    /// - Parameter page: The page to push
    func push(_ page: Page)
    
    /// Presents a sheet modally
    /// - Parameter sheet: The sheet to present
    func present(sheet: Sheet)
    
    /// Presents a full-screen cover
    /// - Parameter fullScreenCover: The full-screen cover to present
    func present(fullScreenCover: FullScreenCover)
    
    /// Pops the current page from the navigation stack
    func pop()
    
    /// Pops to the root page of the navigation stack
    func popToRoot()
    
    /// Dismisses the currently presented sheet
    func dismissSheet()
}

/// Protocol defining the factory methods for creating different screens/views in the application
/// Must be used on the main actor as it creates UI components
@MainActor
public protocol FeatureProviderAPI {
    /// Creates the home screen view
    /// - Parameter coordinator: The coordinator for handling navigation
    /// - Returns: The configured home screen view
    func makeHomeScreen(
        coordinator: CoordinatorApi
    ) -> any View
    
    /// Creates the list items screen view
    /// - Parameter list: The user list to display items from
    /// - Returns: The configured list items screen view
    func makeListItemsScreen(
        list: UserList
    ) -> any View
    
    /// Creates the about screen view
    /// - Returns: The configured about screen view
    func makeAboutScreen() -> any View
    
    /// Creates the share list screen view
    /// - Parameters:
    ///   - coordinator: The coordinator for handling navigation
    ///   - list: The user list to be shared
    /// - Returns: The configured share list screen view
    func makeShareListScreen(
        coordinator: CoordinatorApi,
        list: UserList
    ) -> any View
    
    /// Creates the authentication screen view
    /// - Parameter coordinator: The coordinator for handling navigation
    /// - Returns: The configured authentication screen view
    func makeAuthenticationScreen(
        coordinator: CoordinatorApi
    ) -> any View
    
    /// Creates the app menu view
    /// - Parameter coordinator: The coordinator for handling navigation
    /// - Returns: The configured app menu view
    func makeAppMenuView(
        coordinator: CoordinatorApi
    ) -> any View
}
