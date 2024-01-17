import SwiftUI

struct ShareList {
    struct Builder {
        struct Dependencies: ShareListDependencies {
            var coordinator: Coordinator
            var useCase: ShareListUseCaseApi
            var list: List
        }
        
        @MainActor
        static func makeShareList(
            coordinator: Coordinator,
            list: List
        ) -> ShareListView {
            let dependencies = Dependencies(
                coordinator: coordinator,
                useCase: UseCase(),
                list: list
            )
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return ShareListView(store: store)
        }
    }
}
