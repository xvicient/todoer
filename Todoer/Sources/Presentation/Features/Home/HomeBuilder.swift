import SwiftUI

struct Home {
    struct Builder {
        struct Dependencies: HomeDependencies {
            var useCase: HomeUseCaseApi
            var coordinator: Coordinator
        }
        @MainActor
        static func makeHome(
            coordinator: Coordinator
        ) -> HomeScreen {
            let dependencies = Dependencies(
                useCase: UseCase(),
                coordinator: coordinator
            )
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(store: store)
        }
    }
}
