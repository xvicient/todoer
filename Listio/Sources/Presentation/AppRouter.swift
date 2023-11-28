import SwiftUI

public enum AppRouter: NavigationRouter {
    case authentication
    case home
    case products(String, String)
    case createList
    
    public var transition: NavigationTranisitionStyle {
        switch self {
        case .authentication: return .push
        case .home: return .push
        case .products: return .push
        case .createList: return .presentModally
        }
    }
    
    @MainActor
    @ViewBuilder public func view() -> some View {
        switch self {
        case .authentication:
            AuthenticationBuilder.makeAuthentication()
        case .home:
            HomeBuilder.makeHome()
        case .products(let listId, let listName):
            ProductsBuilder.makeProductList(listId: listId,
                                            listName: listName)
        case .createList:
            CreateListBuilder.makeCreateList()
        }
    }
}
