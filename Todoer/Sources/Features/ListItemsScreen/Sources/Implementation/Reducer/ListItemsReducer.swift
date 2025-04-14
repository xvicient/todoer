import Common
import Entities
import Foundation
import ListItemsScreenContract
import Strings
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
        var viewState: ViewState = .idle
        
        var listName: String
        var items = [Item]()
        var editMode: EditMode = .inactive
        var searchText: String  = ""
        var isSearchFocused: Bool = false
        var activeTab: TDListTabItem = .all
        var tabs: [TDListTab] {
            TDListTab.allCases(
                active: activeTab,
                hidden: [items.count < 2 ? .sort : nil,
                         items.count < 1 ? .edit : nil].compactMap { $0 }
            )

        }
        
        var alert: AppAlert<Action>? {
            guard case .alert(let data) = viewState else {
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
    
    let dependencies: ListItemsReducerDependencies
    
    init(dependencies: ListItemsReducerDependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - Bindings

@MainActor
extension Store<ListItemsReducer> {
    var activeTab: TDListTabItem {
        get { state.activeTab }
        set { send(.didChangeActiveTab(newValue)) }
    }
    
    var tabs: [TDListTab] {
        get { state.tabs }
        set { }
    }
    
    var searchText: String {
        get { state.searchText }
        set { send(.didUpdateSearchText(newValue)) }
    }
    
    var rows: [TDListRow] {
        get {
            state.items
                .filter(by: state.activeTab)
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

extension Item: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete]
    }
}
