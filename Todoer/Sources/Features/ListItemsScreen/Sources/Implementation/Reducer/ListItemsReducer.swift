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

extension ListItems {
    struct Reducer: xRedux.Reducer {

        enum Errors: Error, LocalizedError {
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }

            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

        enum Action: Equatable, StringRepresentable {
            // MARK: - View appear
            /// ListItemsReducer+ViewAppear
            case onAppear

            // MARK: - User actions
            /// ListItemsReducer+UserActions
            case didTapToggleItemButton(UUID)
            case didTapDeleteItemButton(UUID)
            case didTapAddRowButton
            case didTapCancelAddItemButton
            case didTapSubmitItemButton(String)
            case didTapCancelEditItemButton
            case didMoveItem(IndexSet, Int, Bool?)
            case didTapDismissError
            case didTapAutoSortItems
            case didUpdateSearchText(String)

            // MARK: - Results
            /// ListItemsReducer+Results
            case fetchItemsResult(ActionResult<[Item]>)
            case addItemResult(ActionResult<Item>)
            case deleteItemResult(ActionResult<EquatableVoid>)
            case toggleItemResult(ActionResult<EquatableVoid>)
            case moveItemsResult(ActionResult<EquatableVoid>)
        }

        struct State: AppAlertState {
            var viewState: ViewState = .loading
            var items = [WrappedItem]()
            var listName: String
            var searchText = ""
            var tabs: [TDListTab] {
                guard items.filter(\.isEditing).count < 2 else {
                    return TDListTab.allCases
                }
                return TDListTab.allCases.compactMap { $0 == .sort ? nil : $0 }
            }
            func filteredItems(isCompleted: Bool?) -> Binding<[TDListRow]> {
                Binding(
                    get: {
                        items.filter(by: isCompleted).filter(with: searchText).map { $0.tdListRow }
                    },
                    set: { _ in }
                )
            }
            
            init(
                listName: String
            ) {
                self.listName = listName
            }
            
            var isEditing: Bool {
                items.contains { $0.isEditing }
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
            case loading
            case addingItem
            case updatingItem
            case editingItem
            case sortingItems
            case movingItem
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

            var isEditing: Bool {
                switch self {
                case .addingItem, .editingItem:
                    true
                default:
                    false
                }
            }
        }

        internal let dependencies: ListItemsReducerDependencies

        init(dependencies: ListItemsReducerDependencies) {
            self.dependencies = dependencies
        }
    }
}

extension ListItems.Reducer {
    struct WrappedItem: Identifiable, Equatable, ElementSortable {
        var id: UUID {
            item.id
        }
        var item: Item
        let leadingActions: [TDSwipeAction]
        let trailingActions: [TDSwipeAction]
        var isEditing: Bool

        var done: Bool { item.done }
        var name: String { item.name }
        var index: Int {
            get {
                item.index
            }
            set {
                item.index = newValue
            }
        }

        init(
            item: Item,
            leadingActions: [TDSwipeAction] = [],
            trailingActions: [TDSwipeAction] = [],
            isEditing: Bool = false
        ) {
            self.item = item
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.isEditing = isEditing
        }
    }
}

extension Array where Element == ListItems.Reducer.WrappedItem {
    func index(for id: UUID) -> Int? {
        firstIndex { $0.id == id }
    }
    
    mutating func replace(item: Item, at index: Int) {
        remove(at: index)
        insert(item.toItemRow, at: index)
    }
    
    var last: ListItems.Reducer.WrappedItem? {
        self.min(by: { $0.index < $1.index })
    }
    
    mutating func removeLast() {
        if let last {
            removeAll { $0.id == last.id }
        }
    }

}

// MARK: - WrappedItem to TDListRow

extension ListItems.Reducer.WrappedItem {
    fileprivate var tdListRow: TDListRow {
        TDListRow(
            id: item.id,
            name: item.name,
            image: item.done ? Image.largecircleFillCircle : Image.circle,
            strikethrough: item.done,
            leadingActions: leadingActions,
            trailingActions: trailingActions,
            isEditing: isEditing
        )
    }
}

// MARK: - Item to WrappedItem

extension Item {
    var toItemRow: ListItems.Reducer.WrappedItem {
        ListItems.Reducer.WrappedItem(
            item: self,
            leadingActions: [done ? .undone : .done],
            trailingActions: [.delete]
        )
    }
}
