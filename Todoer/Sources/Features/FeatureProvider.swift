import FeatureProviderContract
import HomeScreenContract
import HomeScreen
import SwiftUI
import CoordinatorContract

struct FeatureProvider: FeatureProviderAPI {
    
    @MainActor
    func makeHomeScreen(coordinator: CoordinatorApi) -> any View {
        struct Dependencies: HomeScreenDependencies {
            let coordinator: CoordinatorApi
        }
        return Home.Builder.makeHome(
            dependencies: Dependencies(
                coordinator: coordinator
            )
        )
    }
}
