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
        case didTapSubmitItemButton(UUID, String)
        case didTapCancelButton
        case didTapToggleItemButton(UUID)
        case didTapDeleteItemButton(UUID)
        case didMoveItem(IndexSet, Int)
        case didChangeSearchFocus(Bool)
        case didChangeEditMode(EditMode)
        case didChangeActiveTab(TDListTab)
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
        var activeTab: TDListTab = .all
        var searchText: String  = ""
        var isSearchFocused: Bool = false
        
        var tabs: [TDListTab] {
            guard items.filter(\.isEditing).count > 1 else {
                return TDListTab.allCases
            }
            return TDListTab.allCases.compactMap { $0 == .sort ? nil : $0 }
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
            state.items
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
    
    var isUpdating: Bool {
        switch state.viewState {
        case .updating:
            true
        default:
            false
        }
    }
    
    var isLoading: Bool {
        switch state.viewState {
        case .loading(let isLoading):
            isLoading
        default:
            false
        }
    }
}

// MARK: - TDListRow

extension Item: @retroactive TDListRow {
    public var image: Image {
        done ? Image.largecircleFillCircle : Image.circle
    }
    
    public var leadingActions: [TDListSwipeAction] {
        [done ? .undone : .done]
    }
    
    public var trailingActions: [TDListSwipeAction] {
        [.delete, .share]
    }
    
    public var isEditing: Bool {
        documentId.isEmpty
    }
}
