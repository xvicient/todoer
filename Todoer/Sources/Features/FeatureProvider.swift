import FeatureProviderContract
import HomeScreenContract
import HomeScreen
import SwiftUI
import CoordinatorContract

struct FeatureProvider: FeatureProviderAPI {
    
    @MainActor
    func makeHomeScreen(coordinator: CoordinatorApi) -> any View {
        Home.Builder.makeHome(dependencies: Dependencies(coordinator: coordinator))
    }
}
