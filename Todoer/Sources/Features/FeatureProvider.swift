import SwiftUI
import CoordinatorContract
import FeatureProviderContract
import Entities
import HomeScreenContract
import HomeScreen
import ListItemsScreenContract
import ListItemsScreen

struct FeatureProvider: FeatureProviderAPI {
    
    @MainActor
    func makeHomeScreen(coordinator: CoordinatorApi) -> any View {
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
    func makeListItemsScreen(list: UserList) -> any View {
        struct Dependencies: ListItemsDependencies {
            let list: UserList
        }
        
        return ListItems.Builder.makeItemsList(
            dependencies: Dependencies(
                list: list
            )
        )
    }
}
