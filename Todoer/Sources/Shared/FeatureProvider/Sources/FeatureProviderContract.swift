import SwiftUI
import Entities
import CoordinatorContract

public protocol FeatureProviderAPI {
    @MainActor
    func makeHomeScreen(
        coordinator: CoordinatorApi
    ) -> any View
    
    @MainActor
    func makeListItemsScreen(
        list: UserList
    ) -> any View
    
    @MainActor
    func makeAboutScreen() -> any View
    
    @MainActor
    func makeShareListScreen(
        coordinator: CoordinatorApi,
        list: UserList
    ) -> any View
    
    @MainActor
    func makeAuthenticationScreen(
        coordinator: CoordinatorApi
    ) -> any View
}
