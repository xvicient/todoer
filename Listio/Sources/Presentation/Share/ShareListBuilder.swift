import SwiftUI

struct ShareList {
    struct Builder {
        struct Dependencies: ShareListDependencies {
            var useCase: ShareListUseCaseApi
            var listUids: [String]
        }
        
        @MainActor
        static func makeShareList(
            listUids: [String]
        ) -> ShareListView {
            let dependencies = Dependencies(
                useCase: UseCase(),
                listUids: listUids
            )
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return ShareListView(store: store)
        }
    }
}
