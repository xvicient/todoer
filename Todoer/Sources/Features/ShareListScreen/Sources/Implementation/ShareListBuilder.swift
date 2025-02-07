import CoordinatorContract
import Entities
import ShareListScreenContract
import SwiftUI
import xRedux

public struct ShareList {
    public struct Builder {
        @MainActor
        public static func makeShareList(
            dependencies: ShareListScreenDependencies
        ) -> some View {
            ShareListScreen(
                store: Store(
                    initialState: .init(),
                    reducer: Reducer(
                        dependencies: dependencies,
                        useCase: UseCase()
                    )
                )
            )
        }
    }
}
