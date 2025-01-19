import SwiftUI
import Application
import AppMenuContract

extension AppMenu {
    
    public struct Builder {
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
