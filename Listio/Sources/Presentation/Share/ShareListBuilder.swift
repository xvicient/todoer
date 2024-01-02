import SwiftUI

struct ShareList {
    struct Builder {
        struct Dependencies: ShareListDependencies {
            var useCase: ShareListUseCaseApi
            var list: List
        }
        
        @MainActor
        static func makeShareList(
            list: List
        ) -> ShareListView {
            let dependencies = Dependencies(
                useCase: UseCase(),
                list: list
            )
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return ShareListView(store: store)
        }
    }
}
