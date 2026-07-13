import Common
import CoordinatorContract
import Entities
import Foundation
import HomeScreenContract
import Shared
import Strings
import SwiftUI
import ThemeComponents
import xRedux

// MARK: - HomeReducer

/// Home screen (the user's lists). Wraps `TDListReducer`, which drives the shared list mechanics
/// (add / rename / toggle / delete / reorder / search / edit mode), and adds only the Home-specific
/// behaviour: fetching lists + invitations, importing shared lists on scene activation, and
/// navigation (opening a list, presenting the share sheet).
struct HomeReducer: Reducer {

    typealias SharedReducer = TDListReducer<ListsToggleableUseCase>

    enum Action: Equatable, Sendable, StringRepresentable {
        case shared(SharedReducer.Action)

        // MARK: - View appear
        case onViewAppear
        case onSceneActive

        // MARK: - Navigation
        case didTapList(String)
        case didTapShareListButton(String)

        // MARK: - Results
        case fetchDataResult(ActionResult<HomeData>)
        case addSharedListsResult(ActionResult<[UserList]>)
    }

    struct State: AppAlertState {
        var shared = SharedReducer.State(viewState: .loading(true))
        var invitations = [Invitation]()

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

    let dependencies: HomeScreenDependencies
    let useCase: HomeUseCaseApi
    let sharedReducer: SharedReducer

    init(
        dependencies: HomeScreenDependencies,
        useCase: HomeUseCaseApi = HomeUseCase()
    ) {
        self.dependencies = dependencies
        self.useCase = useCase
        self.sharedReducer = SharedReducer(
            useCase: ListsToggleableUseCase(useCase: useCase)
        )
    }
}

// MARK: - Bindings

@MainActor
extension Store<HomeReducer> {
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

extension UserList: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete, .share]
    }
}
