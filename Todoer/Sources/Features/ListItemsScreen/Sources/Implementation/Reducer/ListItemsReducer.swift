import Common
import Entities
import Foundation
import ListItemsScreenContract
import xRedux
import ThemeComponents
import SwiftUI

// MARK: - ListItemsReducer

protocol ListItemsReducerDependencies {
    var list: UserList { get }
    var useCase: ListItemsUseCaseApi { get }
}

struct ListItemsReducer: Reducer {
    
    enum Action: Equatable, StringRepresentable {
        // MARK: - Actions
        case onAppear
        case didTapSubmitItemButton(String?, String)
        case didTapToggleItemButton(String)
        case didTapDeleteItemButton(String)
        case didMoveItem(IndexSet, Int)
        case didChangeSearchFocus(Bool)
        case didChangeEditMode(EditMode)
        case didChangeActiveTab(TDListTabItem)
        case didUpdateSearchText(String)
        case didTapDismissError
        
        // MARK: - Results
        case fetchItemsResult(ActionResult<[Item]>)
        case addItemResult(ActionResult<Item>)
        case updateItemResult(ActionResult<Item>)
        case voidResult(ActionResult<EquatableVoid>)
        case moveItemResult(ActionResult<EquatableVoid>)
    }
    
    struct State: AppAlertState {
        /// `nonisolated(unsafe)`: the compiler infers MainActor isolation for this
        /// property because `alert` (below, an `AppAlertState` witness) reads it —
        /// same as `items`, `State` is a plain value type only ever touched
        /// through `Store`, which is itself MainActor-bound.
        nonisolated(unsafe) var screen = TDListScreenState<Action>()

        var listName: String
        var items = [Item]()

        var tabs: [TDListTab] {
            TDListTab.allCases(
                active: screen.activeTab,
                hidden: [items.count < 2 ? .sort : nil,
                         items.count < 1 ? .edit : nil].compactMap { $0 }
            )

        }

        var alert: AppAlert<Action>? {
            guard case .alert(let data) = screen.viewState else {
                return nil
            }
            return data
        }

        init(
            listName: String
        ) {
            self.listName = listName
        }
    }

    typealias ViewState = TDListViewState<Action>

    let dependencies: ListItemsReducerDependencies
    
    init(dependencies: ListItemsReducerDependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - Bindings

@MainActor
extension Store<ListItemsReducer> {
    var activeTab: TDListTabItem {
        get { state.screen.activeTab }
        set { send(.didChangeActiveTab(newValue)) }
    }

    var tabs: [TDListTab] {
        get { state.tabs }
        set { }
    }

    var searchText: String {
        get { state.screen.searchText }
        set { send(.didUpdateSearchText(newValue)) }
    }

    var rows: [TDListRow] {
        get {
            state.items
                .filter(by: state.screen.activeTab)
                .filter(by: searchText)
        }
        set { }
    }

    var editMode: EditMode {
        get { state.screen.editMode }
        set { send(.didChangeEditMode(newValue)) }
    }

    var isSearchFocused: Bool {
        get { state.screen.isSearchFocused }
        set { send(.didChangeSearchFocus(newValue)) }
    }

    var isLoading: Bool {
        switch state.screen.viewState {
        case .loading(let isLoading):
            isLoading
        default:
            false
        }
    }

    var contentStatus: TDContentStatus {
        switch state.screen.viewState {
        case .adding: .adding
        case .updating where editMode.isEditing: .editing
        case .idle: .plain
        default: .plain
        }
    }
}

// MARK: - TDListRow

extension Item: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete]
    }
}
