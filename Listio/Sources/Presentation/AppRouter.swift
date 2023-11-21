import SwiftUI

public enum AppRouter: NavigationRouter {
    case home
    case products(String, String)
    
    public var transition: NavigationTranisitionStyle {
        switch self {
        case .home: return .push
        case .products: return .push
        }
    }
    
    @ViewBuilder public func view() -> some View {
        switch self {
        case .home:
            HomeBuilder.makeHome()
        case .products(let listId, let listName):
            ProductsBuilder.makeProductList(listId: listId,
                                            listName: listName)
        }
    }
}
