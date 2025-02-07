import SwiftUI
import xRedux
import AppMenuContract

extension AppMenu {
    
    public struct Builder {
        
        /// Creates and configures the app menu with its dependencies
        /// - Parameter dependencies: Dependencies required by the app menu
        /// - Returns: A view representing the app menu
        @MainActor
        public static func makeAppMenu(
            dependencies: AppMenuDependencies
        ) -> some View {
            let reducer = Reducer(
                dependencies: dependencies,
                useCase: UseCase()
            )
            let store = Store(initialState: .init(), reducer: reducer)
            return AppMenuView(store: store)
        }
    }
}
