import Common
import CoordinatorContract
import Entities
import Foundation
import HomeScreenContract
import Strings
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
        case didTapCancelButton
        case didTapToggleListButton(String)
        case didTapShareListButton(String)
        case didTapDeleteListButton(String)
        case didMoveList(IndexSet, Int)
        case didChangeSearchFocus(Bool)
        case didChangeEditMode(EditMode)
        case didChangeActiveTab(TDListTab)
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
        var viewState = ViewState.loading(true)
        
        var lists = [UserList]()
        var invitations = [Invitation]()
        
        var editMode: EditMode = .inactive
        var activeTab: TDListTab = .all
        var searchText: String  = ""
        var isSearchFocused: Bool = false
        
        var tabs: [TDListTab] {
            TDListTab.tabs(for: lists.count)
        }
        
        var alert: AppAlert<Action>? {
            guard case .alert(let data) = viewState else {
                return nil
                
            }
            return data
        }
    }
    
    enum ViewState: Equatable, StringRepresentable {
        case idle
        case loading(Bool)
        case updating
        case adding
        case alert(AppAlert<Action>)
        
        static func error(
            _ message: String = Errors.default
        ) -> ViewState {
            .alert(
                .init(
                    title: Strings.Errors.errorTitle,
                    message: message,
                    primaryAction: (.didTapDismissError, Strings.Errors.okButtonTitle)
                )
            )
        }
    }
    
    let dependencies: HomeScreenDependencies
    let useCase: HomeUseCaseApi = HomeUseCase()
    
    init(dependencies: HomeScreenDependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - Bindings

@MainActor
extension Store<HomeReducer> {
    var activeTab: TDListTab {
        get { state.activeTab }
        set { send(.didChangeActiveTab(newValue)) }
    }
    
    var searchText: String {
        get { state.searchText }
        set { send(.didUpdateSearchText(newValue)) }
    }
    
    var rows: [TDListRow] {
        get {
            state.lists
                .filter(by: activeTab.isCompleted)
                .filter(by: searchText)
        }
        set { }
    }
    
    var editMode: EditMode {
        get { state.editMode }
        set { send(.didChangeEditMode(newValue)) }
    }
    
    var isSearchFocused: Bool {
        get { state.isSearchFocused }
        set { send(.didChangeSearchFocus(newValue)) }
    }
    
    var isLoading: Bool {
        switch state.viewState {
        case .loading(let isLoading):
            isLoading
        default:
            false
        }
    }
    
    var contentStatus: TDContentStatus {
        switch state.viewState {
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
