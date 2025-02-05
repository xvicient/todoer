import SwiftUI
import Entities
import xRedux
import CoordinatorContract
import ShareListScreenContract

public struct ShareList {
    public struct Builder {@MainActor
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
