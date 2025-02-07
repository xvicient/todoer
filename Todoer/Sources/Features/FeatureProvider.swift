import SwiftUI
import CoordinatorContract
import Entities
import HomeScreenContract
import HomeScreen
import ListItemsScreenContract
import ListItemsScreen
import AboutScreen
import ShareListScreen
import ShareListScreenContract
import AuthenticationScreenContract
import AuthenticationScreen
import AppMenuContract
import AppMenu

/// A provider that creates and configures feature views in the application
/// This type runs on the main actor to ensure thread safety when creating UI components
@MainActor
struct FeatureProvider: FeatureProviderAPI {
    
    /// Creates the home screen view
    /// - Parameter coordinator: The coordinator for handling navigation and app flow
    /// - Returns: A view representing the home screen
    func makeHomeScreen(
        coordinator: CoordinatorApi
    ) -> any View {
        struct Dependencies: HomeScreenDependencies {
            let coordinator: CoordinatorApi
        }
        return Home.Builder.makeHome(
            dependencies: Dependencies(
                coordinator: coordinator
            )
        )
    }
    
    /// Creates the list items screen view
    /// - Parameter list: The list whose items should be displayed
    /// - Returns: A view representing the list items screen
    func makeListItemsScreen(
        list: UserList
    ) -> any View {
        struct Dependencies: ListItemsScreenDependencies {
            let list: UserList
        }
        
        return ListItems.Builder.makeItemsList(
            dependencies: Dependencies(
                list: list
            )
        )
    }
    
    /// Creates the about screen view
    /// - Returns: A view representing the about screen
    func makeAboutScreen() -> any View {
        About.Builder.makeAbout()
    }
    
    /// Creates the share list screen view
    /// - Parameters:
    ///   - coordinator: The coordinator for handling navigation and app flow
    ///   - list: The list to be shared
    /// - Returns: A view representing the share list screen
    func makeShareListScreen(
        coordinator: CoordinatorApi,
        list: UserList
    ) -> any View {
        struct Dependencies: ShareListScreenDependencies {
            let coordinator: CoordinatorApi
            let list: UserList
        }
        
        return ShareList.Builder.makeShareList(
            dependencies: Dependencies(
                coordinator: coordinator,
                list: list
            )
        )
    }
    
    /// Creates the authentication screen view
    /// - Parameter coordinator: The coordinator for handling navigation and app flow
    /// - Returns: A view representing the authentication screen
    func makeAuthenticationScreen(
        coordinator: CoordinatorApi
    ) -> any View {
        struct Dependencies: AuthenticationScreenDependencies {
            let coordinator: CoordinatorApi
        }
        
        return Authentication.Builder.makeAuthentication(
            dependencies: Dependencies(
                coordinator: coordinator
            )
        )
    }
    
    /// Creates the app menu view
    /// - Parameter coordinator: The coordinator for handling navigation and app flow
    /// - Returns: A view representing the app menu
    func makeAppMenuView(
        coordinator: CoordinatorApi
    ) -> any View {
        struct Dependencies: AppMenuDependencies {
            var coordinator: CoordinatorApi
        }
        
        return AppMenu.Builder.makeAppMenu(
            dependencies: Dependencies(coordinator: coordinator)
        )
    }
}
