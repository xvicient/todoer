import Common
import Entities
import ListItemsScreenContract
import ThemeComponents
import SwiftUI
import xRedux
import EntitiesMocks

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
    
    @Bindable private var store: Store<ListItemsReducer<ListItemsUseCase>>

    init(
        store: Store<ListItemsReducer<ListItemsUseCase>>
    ) {
        self.store = store
    }

    var body: some View {
        ZStack {
            TDListView(
                store: store,
                title: store.state.listName,
                onAppear: { store.send(.onAppear) }
            )
            loadingView
        }
    }
}

// MARK: - Loading

extension ListItemsScreen {
    @ViewBuilder
    fileprivate var loadingView: some View {
        if store.isLoading {
            ProgressView()
        }
    }
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: ListItemsScreenDependencies {
        var list: UserList
    }
    
    static var previews: some View {
        ListItemsBuilder.makeItemsList(
            dependencies: Dependencies(
                list: ListMock.list
            )
        )
    }
}
