import SwiftUI
import Entities
import Application
import CoordinatorContract
import ShareListScreenContract

public struct ShareList {
    public struct Builder {@MainActor
        public static func makeShareList(
			dependencies: ShareListScreenDependencies
		) -> some View {
			let reducer = Reducer(
				dependencies: dependencies
			)
			let store = Store(initialState: .init(), reducer: reducer)
			return ShareListScreen(store: store)
		}
	}
}
