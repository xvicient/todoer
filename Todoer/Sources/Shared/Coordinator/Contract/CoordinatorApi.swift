import SwiftUI
import Data
import Entities

public enum Page: Hashable, Identifiable {
    case authentication
    case home
    case listItems(UserList)
    case about
    case menu

    public var id: Self { self }
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
    func push(_ page: Page)
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
