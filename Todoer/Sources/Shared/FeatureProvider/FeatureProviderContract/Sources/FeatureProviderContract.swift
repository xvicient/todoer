import HomeScreenContract
import CoordinatorContract
import SwiftUI

public protocol FeatureProviderAPI {
    @MainActor
    func makeHomeScreen(coordinator: CoordinatorApi) -> any View
}
