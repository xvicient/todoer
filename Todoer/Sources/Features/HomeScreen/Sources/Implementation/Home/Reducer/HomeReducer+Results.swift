import Entities
import xRedux

// MARK: - Reducer results

extension Home.Reducer {

    @MainActor
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = .idle
            
            state.userUid = data.userUid
            state.lists = data.lists.map { $0.toListRow }
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
                state.lists.insert(contentsOf: lists.map { $0.toListRow }, at: 0)
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
        guard let index = state.lists.firstIndex(where: { $0.isEditing }) else {
            state.viewState = .error()
            return .none
        }
        state.lists.remove(at: index)

        switch result {
        case .success(let list):
            state.lists.insert(list.toListRow, at: index)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onResult(
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
