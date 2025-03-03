import Entities
import xRedux

// MARK: - Reducer results

@MainActor
extension ShareList.Reducer {
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<ShareData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewModel.users = data.users
            state.viewModel.selfName = data.selfName
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
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
