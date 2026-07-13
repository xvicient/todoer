import Common
import Entities
import Foundation
import ListItemsScreenContract
import Shared
import Strings
import SwiftUI
import ThemeComponents
import xRedux

// MARK: - ListItemsReducer

protocol ListItemsReducerDependencies {
    var list: UserList { get }
    var useCase: ListItemsUseCaseApi { get }
}

/// Items of a single list. Wraps `TDListReducer`, which drives the shared list mechanics
/// (add / rename / toggle / delete / reorder / search / edit mode), and adds only the
/// item-specific fetch on appear.
struct ListItemsReducer: Reducer {

    typealias SharedReducer = TDListReducer<ItemsToggleableUseCase>

    enum Action: Equatable, Sendable, StringRepresentable {
        case shared(SharedReducer.Action)
        case onAppear
        case fetchItemsResult(ActionResult<[Item]>)
    }

    struct State: AppAlertState {
        var shared = SharedReducer.State()
        let listName: String

        init(listName: String) {
            self.listName = listName
        }

        var alert: AppAlert<Action>? {
            guard let message = shared.errorMessage else {
                return nil
            }
            return AppAlert(
                title: Strings.Errors.errorTitle,
                message: message,
                primaryAction: (.shared(.didTapDismissError), Strings.Errors.okButtonTitle)
            )
        }
    }

    let dependencies: ListItemsReducerDependencies
    let sharedReducer: SharedReducer

    init(dependencies: ListItemsReducerDependencies) {
        self.dependencies = dependencies
        self.sharedReducer = SharedReducer(
            useCase: ItemsToggleableUseCase(
                useCase: dependencies.useCase,
                list: dependencies.list
            )
        )
    }
}

// MARK: - Bindings

@MainActor
extension Store<ListItemsReducer> {
    var activeTab: TDListTabItem {
        get { state.shared.activeTab }
        set { send(.shared(.didChangeActiveTab(newValue))) }
    }

    var tabs: [TDListTab] {
        get { state.shared.tabs }
        set { }
    }

    var searchText: String {
        get { state.shared.searchText }
        set { send(.shared(.didUpdateSearchText(newValue))) }
    }

    var rows: [TDListRow] {
        get { state.shared.filteredRows() }
        set { }
    }

    var editMode: EditMode {
        get { state.shared.editMode }
        set { send(.shared(.didChangeEditMode(newValue))) }
    }

    var isSearchFocused: Bool {
        get { state.shared.isSearchFocused }
        set { send(.shared(.didChangeSearchFocus(newValue))) }
    }

    var isLoading: Bool {
        state.shared.isLoading
    }

    var contentStatus: TDContentStatus {
        state.shared.contentStatus
    }
}

// MARK: - TDListRow

extension Item: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete]
    }
}
