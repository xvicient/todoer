import FeatureProviderContract
import HomeScreenContract
import HomeScreen
import SwiftUI

struct FeatureProvider: FeatureProviderAPI {
    @MainActor
    var makeHomeScreen: MakeHomeScreen = Home.Builder.makeHome
}
