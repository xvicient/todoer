// MARK: - Reducer results

@MainActor
internal extension Home.Reducer {    
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = .idle
            state.viewModel.lists = data.lists.map { $0.toListRow }
            state.viewModel.invitations = data.invitations
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onPhotoUrlResult(
        state: inout State,
        result: ActionResult<String>
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
        result: ActionResult<List>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onDeleteListResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onAcceptInvitationResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onDeclineInvitationResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: ActionResult<List>
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.firstIndex(where: { $0.isEditing }) else {
            state.viewState = .alert(.error(Errors.default))
            return .none
        }
        state.viewModel.lists.remove(at: index)
        
        switch result {
        case .success(let list):
            state.viewModel.lists.insert(list.toListRow, at: index)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .alert(.error(error.localizedDescription))
        }
        return .none
    }
    
    func onSortListsResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
    
    func onDeleteAccountResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            dependencies.coordinator.loggOut()
        case .failure:
            state.viewState = .alert(.error(Errors.default))
        }
        return .none
    }
}
