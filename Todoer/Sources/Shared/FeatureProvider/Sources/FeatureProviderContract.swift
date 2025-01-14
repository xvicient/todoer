import SwiftUI
import Entities
import HomeScreenContract
import CoordinatorContract

public protocol FeatureProviderAPI {
    @MainActor
    func makeHomeScreen(coordinator: CoordinatorApi) -> any View
    
    @MainActor
    func makeListItemsScreen(list: UserList) -> any View
}
