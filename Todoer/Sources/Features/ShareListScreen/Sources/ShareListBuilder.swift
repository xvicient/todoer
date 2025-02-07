import SwiftUI
import Entities
import Application
import CoordinatorContract
import ShareListScreenContract

/// Builder for creating and configuring ShareList screen instances
public struct ShareList {
    public struct Builder {
        /// Creates a new ShareList screen instance
        /// - Parameters:
        ///   - list: List to share
        ///   - usersRepository: Repository for managing users
        /// - Returns: Configured ShareList screen view
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

