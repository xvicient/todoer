import SwiftUI
import CoordinatorContract
import FeatureProviderContract
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

struct FeatureProvider: FeatureProviderAPI {
    
    @MainActor
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
    
    @MainActor
    func makeListItemsScreen(
        list: UserList
    ) -> any View {
        struct Dependencies: ListItemsDependencies {
            let list: UserList
        }
        
        return ListItems.Builder.makeItemsList(
            dependencies: Dependencies(
                list: list
            )
        )
    }
    
    @MainActor
    func makeAboutScreen() -> any View {
        About.Builder.makeAbout()
    }
    
    @MainActor
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
    
    @MainActor
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
