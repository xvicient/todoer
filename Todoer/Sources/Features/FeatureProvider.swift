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

@MainActor
struct FeatureProvider: FeatureProviderAPI {
    
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
    
    func makeAboutScreen() -> any View {
        About.Builder.makeAbout()
    }
    
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
}
