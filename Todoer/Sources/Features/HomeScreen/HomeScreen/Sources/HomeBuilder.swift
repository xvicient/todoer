import SwiftUI
import Application
import HomeScreenContract

public struct Home {
    public struct Builder {
        @MainActor
        public static func makeHome(
            dependencies: HomeDependencies
        ) -> some View {
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(store: store)
        }
    }
}
