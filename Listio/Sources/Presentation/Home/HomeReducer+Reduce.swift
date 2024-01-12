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
            return onDidTapAcceptInvitation(
                state: &state,
                listId: listId,
                invitationId: invitationId
            )
            
        case (.idle, .didTapDeclineInvitation(let invitationId)):
            return onDidTapDeclineInvitation(
                state: &state,
                invitationId: invitationId
            )
            
        case (.idle, .didTapList(let index)):
            return onDidTapList(
                state: &state,
                index: index
            )
        
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
            
        case (_, .acceptInvitationResult(let result)):
            return onAcceptInvitationResult(
                state: &state,
                result: result
            )
            
        case (_, .declineInvitationResult(let result)):
            return onDeclineInvitationResult(
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
    
    func onDidTapAcceptInvitation(
        state: inout State,
        listId: String,
        invitationId: String
    ) -> Effect<Action> {
        return .task(Task {
            .acceptInvitationResult(
                await dependencies.useCase.acceptInvitation(
                        listId: listId,
                        invitationId: invitationId)
            )
        })
    }
    
    func onDidTapDeclineInvitation(
        state: inout State,
        invitationId: String
    ) -> Effect<Action> {
        return .task(Task {
            .declineInvitationResult(
                await dependencies.useCase.declineInvitation(
                        invitationId: invitationId)
            )
        })
    }
    
    func onDidTapList(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.listsSection.rows[index] as? List else {
            state.viewState = .unexpectedError
            return .none
        }
        dependencies.coordinator.push(.listItems(list))
        return .none
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
}
