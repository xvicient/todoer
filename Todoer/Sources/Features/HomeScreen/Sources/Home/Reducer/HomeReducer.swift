import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import HomeScreenContract
import Strings

// MARK: - HomeReducer

typealias HomeData = Home.HomeData

extension Home {
    /// Reducer responsible for managing the home screen's state and actions
    struct Reducer: Application.Reducer {
        /// Possible errors that can occur in the reducer
        enum Errors: Error, LocalizedError {
            /// Generic unexpected error
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }

            /// Default error message
            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

        /// Actions that can be performed in the home screen
        enum Action: Equatable {
            // MARK: - View appear
            /// Action triggered when the view appears
            case onViewAppear

            // MARK: - User actions
            /// Action when a list is tapped
            case didTapList(UUID)
            /// Action when the toggle button of a list is tapped
            case didTapToggleListButton(UUID)
            /// Action when the delete button of a list is tapped
            case didTapDeleteListButton(UUID)
            /// Action when the share button of a list is tapped
            case didTapShareListButton(UUID)
            /// Action when the edit button of a list is tapped
            case didTapEditListButton(UUID)
            /// Action when a list is updated with a new name
            case didTapUpdateListButton(UUID, String)
            /// Action when list editing is cancelled
            case didTapCancelEditListButton(UUID)
            /// Action when the add row button is tapped
            case didTapAddRowButton
            /// Action when adding a new list is cancelled
            case didTapCancelAddListButton
            /// Action when a new list is submitted
            case didTapSubmitListButton(String)
            /// Action when lists are manually sorted
            case didSortLists(IndexSet, Int)
            /// Action when an error is dismissed
            case didTapDismissError
            /// Action when auto-sort is triggered
            case didTapAutoSortLists

            // MARK: - Results
            /// Result of fetching home data
            case fetchDataResult(ActionResult<HomeData>)
            /// Result of toggling a list's status
            case toggleListResult(ActionResult<UserList>)
            /// Result of deleting a list
            case deleteListResult(ActionResult<EquatableVoid>)
            /// Result of adding a new list
            case addListResult(ActionResult<UserList>)
            /// Result of sorting lists
            case sortListsResult(ActionResult<EquatableVoid>)
            /// Result of deleting the account
            case deleteAccountResult(ActionResult<EquatableVoid>)
        }

        /// State of the home screen
        struct State: AppAlertState {
            /// Current view state
            var viewState = ViewState.idle
            /// View model containing UI data
            var viewModel = ViewModel()
            
            /// Current alert being displayed, if any
            var alert: AppAlert<Action>? {
                guard case .alert(let data) = viewState else {
                    return nil
                }
                return data
            }
        }

        /// Different states the view can be in
        enum ViewState: Equatable {
            /// Default state
            case idle
            /// Loading state
            case loading
            /// Adding a new list
            case addingList
            /// Sorting lists
            case sortingList
            /// Updating an existing list
            case updatingList
            /// Editing an existing list
            case editingList
            /// Showing an alert
            case alert(AppAlert<Action>)
            
            /// Creates an error state with a message
            /// - Parameter message: Error message to display
            /// - Returns: Alert view state
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

        /// Dependencies required by the reducer
        internal let dependencies: HomeScreenDependencies
        /// Use case for business logic
        internal let useCase: HomeUseCaseApi = UseCase()

        /// Initializes the reducer with required dependencies
        /// - Parameter dependencies: Dependencies for the home screen
        init(dependencies: HomeScreenDependencies) {
            self.dependencies = dependencies
        }

        // MARK: - Reduce

        /// Handles state changes based on actions
        /// - Parameters:
        ///   - state: Current state to modify
        ///   - action: Action that triggered the state change
        /// - Returns: Effect to execute
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {

            switch (state.viewState, action) {
            case (.idle, .onViewAppear):
                return onAppear(
                    state: &state
                )

            case (.idle, .didTapList(let rowId)):
                return onDidTapList(
                    state: &state,
                    uid: rowId
                )

            case (.idle, .didTapToggleListButton(let rowId)):
                return onDidTapToggleListButton(
                    state: &state,
                    uid: rowId
                )

            case (.idle, .didTapDeleteListButton(let rowId)):
                return onDidTapDeleteListButton(
                    state: &state,
                    uid: rowId
                )

            case (.idle, .didTapShareListButton(let rowId)):
                return onDidTapShareListButton(
                    state: &state,
                    uid: rowId
                )

            case (.idle, .didTapEditListButton(let rowId)):
                return onDidTapEditListButton(
                    state: &state,
                    uid: rowId
                )

            case (.editingList, .didTapCancelEditListButton(let rowId)):
                return onDidTapCancelEditListButton(
                    state: &state,
                    uid: rowId
                )

            case (.editingList, .didTapUpdateListButton(let uid, let name)):
                return onDidTapUpdateListButton(
                    state: &state,
                    uid: uid,
                    name: name
                )

            case (.idle, .didTapAddRowButton):
                return onDidTapAddRowButton(
                    state: &state
                )

            case (.addingList, .didTapCancelAddListButton):
                return onDidTapCancelAddListButton(
                    state: &state
                )

            case (.addingList, .didTapSubmitListButton(let name)):
                return onDidTapSubmitListButton(
                    state: &state,
                    newListName: name
                )

            case (.idle, .didSortLists(let fromIndex, let toIndex)):
                return onDidSortLists(
                    state: &state,
                    fromIndex: fromIndex,
                    toIndex: toIndex
                )

            case (.alert, .didTapDismissError):
                return onDidTapDismissError(
                    state: &state
                )

            case (.idle, .didTapAutoSortLists):
                return onDidTapAutoSortLists(
                    state: &state
                )
            
            // sortingList uses firestore batch that triggers the collection listener so the fetch is being triggered as well
            case (.idle, .fetchDataResult(let result)),
                (.loading, .fetchDataResult(let result)),
                (.addingList, .fetchDataResult(let result)),
                (.editingList, .fetchDataResult(let result)),
                (.sortingList, .fetchDataResult(let result)):
                return onFetchDataResult(
                    state: &state,
                    result: result
                )

            case (.updatingList, .toggleListResult(let result)):
                return onToggleListResult(
                    state: &state,
                    result: result
                )

            case (.updatingList, .deleteListResult(let result)):
                return onDeleteListResult(
                    state: &state,
                    result: result
                )

            case (.addingList, .addListResult(let result)),
                (.editingList, .addListResult(let result)):
                return onAddListResult(
                    state: &state,
                    result: result
                )

            // As fetchDataResult can be triggered by sortListsResult first it will set the idle viewState
            case (.idle, .sortListsResult(let result)),
                (.sortingList, .sortListsResult(let result)):
                return onSortListsResult(
                    state: &state,
                    result: result
                )

            case (.alert, .deleteAccountResult(let result)):
                return onDeleteAccountResult(
                    state: &state,
                    result: result
                )

            default:
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}

// MARK: - UserList to ListRow

extension UserList {
    /// Converts a UserList to a list row with appropriate actions
    var toListRow: Home.Reducer.WrappedUserList {
        .init(
            id: id,
            list: self,
            leadingActions: [done ? .undone : .done],
            trailingActions: [.share, .edit, .delete]
        )
    }
}
