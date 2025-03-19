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

typealias HomeData = Home.HomeData

extension Home {
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
            /// HomeReducer+ViewAppear
            case onViewAppear
            case onSceneActive

            // MARK: - User actions
            /// HomeReducer+UserActions
            case didTapList(UUID)
            case didTapAddListButton
            case didTapSubmitListButton(String)
            case didTapCancelButton
            case didTapEditButton
            case didTapToggleListButton(UUID)
            case didTapShareListButton(UUID)
            case didTapDeleteListButton(UUID)
            case didMoveList(IndexSet, Int, Bool?)
            case didTapAutoSortLists
            case didTapDismissError
            case didChangeSearchFocus(Bool)
            case didChangeEditMode(EditMode)

            // MARK: - Results
            /// HomeReducer+Results
            case fetchDataResult(ActionResult<HomeData>)
            case addListResult(ActionResult<UserList>)
            case toggleListResult(ActionResult<EquatableVoid>)
            case deleteListResult(ActionResult<EquatableVoid>)
            case addSharedListsResult(ActionResult<[UserList]>)
            case moveListsResult(ActionResult<EquatableVoid>)
        }

        @MainActor
        struct State: AppAlertState {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
            
            init(viewState: ViewState = ViewState.idle, viewModel: ViewModel = ViewModel()) {
                self.viewState = viewState
                self.viewModel = viewModel
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
            
            var isLoading: Bool {
                switch self {
                case .loading(let isLoading):
                    return isLoading
                default:
                    return false
                }
            }
        }

        let dependencies: HomeScreenDependencies
        let useCase: HomeUseCaseApi = UseCase()

        init(dependencies: HomeScreenDependencies) {
            self.dependencies = dependencies
        }
    }
}

// MARK: - UserList to ListRow

extension UserList {
    var toListRow: Home.Reducer.WrappedUserList {
        Home.Reducer.WrappedUserList(
            id: id,
            list: self,
            leadingActions: [done ? .undone : .done],
            trailingActions: [.delete, .share]
        )
    }
}
