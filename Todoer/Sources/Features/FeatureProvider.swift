import AboutScreen
import AppMenu
import AppMenuContract
import AuthenticationScreen
import AuthenticationScreenContract
import CoordinatorContract
import Entities
import HomeScreen
import HomeScreenContract
import ListItemsScreen
import ListItemsScreenContract
import ShareListScreen
import ShareListScreenContract
import SwiftUI

@MainActor
struct FeatureProvider: FeatureProviderAPI {

    func makeHomeScreen(
        coordinator: CoordinatorApi
    ) -> any View {
        struct Dependencies: HomeScreenDependencies {
            let coordinator: CoordinatorApi
        }
        return HomeBuilder.makeHome(
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

        return ListItemsBuilder.makeItemsList(
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
