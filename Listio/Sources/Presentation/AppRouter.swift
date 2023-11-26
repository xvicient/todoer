import SwiftUI

public enum AppRouter: NavigationRouter {
    case home
    case products(String, String)
    case createList
    
    public var transition: NavigationTranisitionStyle {
        switch self {
        case .home: return .push
        case .products: return .push
        case .createList: return .presentModally
        }
    }
    
    @ViewBuilder public func view() -> some View {
        switch self {
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
