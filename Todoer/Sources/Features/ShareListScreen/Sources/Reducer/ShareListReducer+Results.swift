import Entities
import Application

// MARK: - Reducer results

/// Extension handling result actions in the ShareList reducer
@MainActor
extension ShareList.Reducer {
    /// Handles the result of fetching share data
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result containing either the share data or an error
    /// - Returns: No effect is produced
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<ShareData>
    ) -> Effect<Action> {
        if case .success(let data) = result {
            state.viewModel.users = data.users
            state.viewModel.selfName = data.selfName
        }
        return .none
    }

    /// Handles the result of sharing a list
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result indicating success or failure of the share operation
    /// - Returns: No effect is produced
    func onShareListResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            dependencies.coordinator.dismissSheet()
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
}
