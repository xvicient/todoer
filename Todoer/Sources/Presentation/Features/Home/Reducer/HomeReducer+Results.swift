// MARK: - Reducer results

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
            state.viewState = .error(Errors.default)
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
            state.viewState = .error(Errors.default)
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
            state.viewState = .error(Errors.default)
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
            state.viewState = .error(Errors.default)
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
            state.viewState = .error(Errors.default)
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: Result<List, Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            if let index = state.viewModel.lists.firstIndex(where: { $0.isEditing }) {
                state.viewState = .idle
                state.viewModel.lists.remove(at: index)
                state.viewModel.lists.insert(list.toListRow, at: index)
            } else {
                state.viewState = .error(Errors.default)
            }
        case .failure:
            state.viewState = .error(Errors.default)
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
            state.viewState = .error(Errors.default)
        }
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
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
