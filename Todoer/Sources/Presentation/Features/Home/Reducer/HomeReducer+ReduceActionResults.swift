import Combine
import Foundation

// MARK: - View appear

@MainActor
internal extension Home.Reducer {    
    func onFetchDataResult(
        state: inout State,
        result: Result<([List], [Invitation]), Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = .idle
            state.viewModel.lists = data.0.map { $0.toListRow }
            state.viewModel.invitations = data.1
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onPhotoUrlResult(
        state: inout State,
        result: Result<String, Error>
    ) -> Effect<Action> {
        state.viewState = .idle
        switch result {
        case .success(let photoUrl):
            state.viewModel.photoUrl = photoUrl
        case .failure:
            break
        }
        return .none
    }
    
    func onToggleListResult(
        state: inout State,
        result: Result<List, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onDeleteListResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onAcceptInvitationResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onDeclineInvitationResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: Result<List, Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            state.viewState = .idle
            state.viewModel.lists.removeAll { $0.isEditing }
            state.viewModel.lists.append(list.toListRow)
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onSortListsResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
}

// MARK: - List to ListRow

private extension List {
    var toListRow: Home.Reducer.ListRow {
        Home.Reducer.ListRow(
            list: self,
            leadingActions: [self.done ? .undone : .done],
            trailingActions: [.delete, .share, .edit]
        )
    }
}
