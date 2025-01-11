import Data

public enum Page: Hashable, Identifiable {
    case authentication
    case home
    case listItems(UserList)
    case about

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
    func loggOut()
    func loggIn()
    func push(_ page: Page)
    func present(sheet: Sheet)
    func present(fullScreenCover: FullScreenCover)
    func pop()
    func popToRoot()
    func dismissSheet()
}
