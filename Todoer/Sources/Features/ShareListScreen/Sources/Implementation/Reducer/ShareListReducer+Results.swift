import Entities
import xRedux

// MARK: - Reducer results

@MainActor
extension ShareList.Reducer {
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
