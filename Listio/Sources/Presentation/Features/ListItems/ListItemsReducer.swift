import Combine
import SwiftUI

// MARK: - ListItemsReducer

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

extension ListItems {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View appear
            case onAppear
            
            // MARK: - User actions
            case didTapToggleItemButton(Int)
            case didTapDeleteItemButton(Int)
            case didTapAddRowButton
            case didTapCancelAddRowButton
            case didTapSubmitItemButton(String)
            
            // MARK: - Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case updateItemResult(Result<Item, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }
        
        enum ViewState {
            case idle
            case loading
            case addingItem
            case unexpectedError
        }
        
        internal let dependencies: ListItemsDependencies
        
        init(dependencies: ListItemsDependencies) {
            self.dependencies = dependencies
        }
    }
}

// MARK: - Private

internal extension ListItems.Reducer {
    
    // MARK: - ViewModel
    
    @MainActor
    struct ViewModel {
        var itemsSection = ItemsSection()
    }
    
    // MARK: - ItemsSection
    
    final class ItemsSection: TDListSectionViewModel {
        var rows: [any TDSectionRow] = []
        var leadingActions: (any TDSectionRow) -> [TDSectionRowActionType] {
            { [$0.done ? .undone : .done] }
        }
        var trailingActions = [TDSectionRowActionType.delete]
    }
    
    // MARK: - EmptyRow
    
    struct EmptyRow: TDSectionRow {
        var id = UUID()
        var documentId = ""
        var name = ""
        var done = false
        var isEditing = true
    }
}
