import Common
import Entities
import Foundation
import ListItemsScreenContract
import ThemeComponents
import Strings
import SwiftUI
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

    struct State: AppAlertState, TDListSharedState {
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

// MARK: - TDListSharedReducer

extension ListItemsReducer: TDListSharedReducer {
    static func shared(_ action: SharedReducer.Action) -> Action {
        .shared(action)
    }
}

// MARK: - TDListRow

extension Item: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete]
    }
}
