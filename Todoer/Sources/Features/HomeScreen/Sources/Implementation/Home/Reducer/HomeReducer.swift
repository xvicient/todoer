import Common
import CoordinatorContract
import Entities
import Foundation
import HomeScreenContract
import xRedux
import ThemeComponents
import SwiftUI

// MARK: - HomeReducer

struct HomeReducer: Reducer {
    
    enum Action: Equatable, StringRepresentable {
        // MARK: - View appear
        /// HomeReducer+ViewAppear
        case onViewAppear
        case onSceneActive
        
        // MARK: - User actions
        /// HomeReducer+UserActions
        case didTapList(String)
        case didTapSubmitListButton(String?, String)
        case didTapToggleListButton(String)
        case didTapShareListButton(String)
        case didTapDeleteListButton(String)
        case didMoveList(IndexSet, Int)
        case didChangeSearchFocus(Bool)
        case didChangeEditMode(EditMode)
        case didChangeActiveTab(TDListTabItem)
        case didUpdateSearchText(String)
        case didTapDismissError
        
        // MARK: - Results
        /// HomeReducer+Results
        case fetchDataResult(ActionResult<HomeData>)
        case addListResult(ActionResult<UserList>)
        case updateListResult(ActionResult<UserList>)
        case addSharedListsResult(ActionResult<[UserList]>)
        case voidResult(ActionResult<EquatableVoid>)
        case moveListResult(ActionResult<EquatableVoid>)
    }
    
    struct State: AppAlertState {
        /// `nonisolated(unsafe)`: the compiler infers MainActor isolation for this
        /// property because `alert` (below, an `AppAlertState` witness) reads it —
        /// same as `lists`/`invitations`, `State` is a plain value type only ever
        /// touched through `Store`, which is itself MainActor-bound.
        nonisolated(unsafe) var screen = TDListScreenState<Action>(viewState: .loading(true))

        var lists = [UserList]()
        var invitations = [Invitation]()

        var tabs: [TDListTab] {
            TDListTab.allCases(
                active: screen.activeTab,
                hidden: [lists.count < 2 ? .sort : nil,
                         lists.count < 1 ? .edit : nil].compactMap { $0 }
            )
        }

        var alert: AppAlert<Action>? {
            guard case .alert(let data) = screen.viewState else {
                return nil
            }
            return data
        }
    }

    typealias ViewState = TDListViewState<Action>

    let dependencies: HomeScreenDependencies
    let useCase: HomeUseCaseApi

    init(
        dependencies: HomeScreenDependencies,
        useCase: HomeUseCaseApi = HomeUseCase()
    ) {
        self.dependencies = dependencies
        self.useCase = useCase
    }
}

// MARK: - Bindings

@MainActor
extension Store<HomeReducer> {
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
            state.lists
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

extension UserList: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete, .share]
    }
}
