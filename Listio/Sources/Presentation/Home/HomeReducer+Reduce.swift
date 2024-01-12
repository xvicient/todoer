import Combine

// MARK: - Home Reducer

internal extension Home.Reducer {    
    @MainActor
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        
        switch (state.viewState, action) {
        case (.idle, .onViewAppear):
            return onViewAppear(
                state: &state
            )
        
        case (_, .onProfilePhotoAppear):
            return onProfilePhotoAppear(
                state: &state
            )
            
        case (.idle, .didTapAcceptInvitation(let listId, let invitationId)):
            return .none
            
        case (.idle, .didTapDeclinedInvitation(let listId)):
            return .none
            
        case (.idle, .didTapList(let index)):
            return .none
        
        case (.idle, .didTapToggleListButton(let index)):
            return .none
            
        case (.idle, .didTapDeleteListButton(let index)):
            return .none
            
        case (.idle, .didTapShareListButton(let index)):
            return onDidTapShareListButton(
                state: &state,
                index: index
            )
            
        case (.idle, .didTapAddRowButton):
            return .none
            
        case (.idle, .didTapCancelAddRowButton):
            return .none
            
        case (.idle, .didTapSubmitListButton(let name)):
            return .none
            
        case (.idle, .didTapSignoutButton):
            return onDidTapSignoutButton(
                state: &state
            )
            
        case (.loading, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (_, .getPhotoUrlResult(let result)):
            return onPhotoUrlResult(
                state: &state,
                result: result
            )
        
        default: return .none
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension Home.Reducer {
    func onViewAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .publish(
            dependencies.useCase.fetchData()
                .map { .fetchDataResult(.success($0)) }
                .catch { Just(.fetchDataResult(.failure($0))) }
                .eraseToAnyPublisher()
            )
    }
    
    func onProfilePhotoAppear(
        state: inout State
    ) -> Effect<Action> {
        return .task(Task {
            .getPhotoUrlResult(
                await dependencies.useCase.getPhotoUrl()
            )
        })
    }
    
    func onDidTapShareListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.listsSection.rows[index] as? List else {
            state.viewState = .unexpectedError
            return .none
        }
        dependencies.coordinator.present(sheet: .shareList(list))

        return .none
    }
    
    func onDidTapSignoutButton(
        state: inout State
    ) -> Effect<Action> {
        switch dependencies.useCase.signOut() {
        case .success:
            dependencies.coordinator.loggOut()
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onFetchDataResult(
        state: inout State,
        result: Result<([List], [Invitation]), Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = .idle
            state.viewModel.listsSection.rows = data.0
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
        switch result {
        case .success(let photoUrl):
            state.viewModel.photoUrl = photoUrl
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
}
