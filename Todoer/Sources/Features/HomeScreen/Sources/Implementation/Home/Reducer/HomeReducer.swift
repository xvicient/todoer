import Common
import CoordinatorContract
import Entities
import Foundation
import HomeScreenContract
import ThemeComponents
import Strings
import SwiftUI
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

    struct State: AppAlertState, TDListSharedState {
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

// MARK: - TDListSharedReducer

extension HomeReducer: TDListSharedReducer {
    static func shared(_ action: SharedReducer.Action) -> Action {
        .shared(action)
    }
}

// MARK: - TDListRow

extension UserList: @retroactive TDListRow {
    public var trailingActions: [TDListSwipeAction] {
        [.delete, .share]
    }
}
