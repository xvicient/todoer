import Data
import Entities
import SwiftUI

public enum Screen: Identifiable, Hashable, Equatable {
    case authentication
    case home
    case listItems(UserList)
    case about
    case menu

    public var id: String {
        switch self {
        case .listItems(let id):
            "listItems\(id)"
        case .authentication:
            "authentication"
        case .home:
            "home"
        case .about:
            "about"
        case .menu:
            "menu"
        }
    }
}

public enum Sheet: Hashable, Identifiable {
    case shareList(UserList)

    public var id: Self { self }
}

public enum FullScreenCover: Hashable, Identifiable {
    case home

    public var id: Self { self }
}

@MainActor
public protocol CoordinatorApi {
    var isUserLogged: Bool { get }
    func loggOut()
    func loggIn()
    func push(_ screen: Screen)
    func present(sheet: Sheet)
    func present(fullScreenCover: FullScreenCover)
    func pop()
    func popToRoot()
    func dismissSheet()
}

@MainActor
public protocol FeatureProviderAPI {
    func makeHomeScreen(
        coordinator: CoordinatorApi
    ) -> any View
    func makeListItemsScreen(
        list: UserList
    ) -> any View
    func makeAboutScreen() -> any View
    func makeShareListScreen(
        coordinator: CoordinatorApi,
        list: UserList
    ) -> any View
    func makeAuthenticationScreen(
        coordinator: CoordinatorApi
    ) -> any View
    func makeAppMenuView(
        coordinator: CoordinatorApi
    ) -> any View
}
