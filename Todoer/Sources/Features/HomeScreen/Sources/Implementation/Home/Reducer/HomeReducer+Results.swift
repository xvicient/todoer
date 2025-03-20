import Entities
import xRedux

// MARK: - Reducer results

extension Home.Reducer {

    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = state.viewState == .updating ? .updating : .idle
            
            state.lists = data.lists
            state.invitations = data.invitations
        case .failure:
            state.viewState = .error()
        }
        return .none
    }

    func onAddSharedListsResult(
        state: inout State,
        result: ActionResult<[UserList]>
    ) -> Effect<Action> {
        state.viewState = .idle
        switch result {
        case .success(let lists):
            if !lists.isEmpty {
                state.lists.insert(contentsOf: lists.map { $0 }, at: 0)
            }
        case .failure:
            break
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            guard let index = state.lists.firstIndex(where: { $0.documentId == list.documentId }) else {
                state.viewState = .error()
                return .none
            }
            state.lists.replace(list, at: index)
            state.viewState = .updating
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onHomeResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }
}
