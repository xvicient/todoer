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
            return onDidTapToggleListButton(
                state: &state,
                index: index
            )
            
        case (.idle, .didTapDeleteListButton(let index)):
            return onDidTapDeleteListButton(
                state: &state,
                index: index
            )
            
        case (.idle, .didTapShareListButton(let index)):
            return onDidTapShareListButton(
                state: &state,
                index: index
            )
            
        case (.idle, .didTapAddRowButton):
            return onDidTapAddRowButton(
                state: &state
            )
            
        case (.addingList, .didTapCancelAddRowButton):
            return onDidTapCancelAddRowButton(
                state: &state
            )
            
        case (.addingList, .didTapSubmitListButton(let name)):
            return onDidTapSubmitListButton(
                state: &state,
                newListName: name
            )
            
        case (.idle, .didTapSignoutButton):
            return onDidTapSignoutButton(
                state: &state
            )
            
        case (.idle, .fetchDataResult(let result)),
            (.loading, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (_, .getPhotoUrlResult(let result)):
            return onPhotoUrlResult(
                state: &state,
                result: result
            )
            
        case (_, .toggleListResult(let result)):
            return onToggleListResult(
                state: &state,
                result: result
            )
            
        case (_, .deleteListResult(let result)):
            return onDeleteListResult(
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
            
        case (_, .addListResult(let result)):
            return onAddListResult(
                state: &state,
                result: result
            )
        
        default:
            Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
            return .none
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
    
    func onDidTapToggleListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.listsSection.rows[index] as? List else {
            state.viewState = .unexpectedError
            return .none
        }
        return .task(Task {
            .toggleListResult(
                await dependencies.useCase.toggleList(list: list)
            )
        })
    }
    
    func onDidTapDeleteListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.listsSection.rows[index] as? List else {
            state.viewState = .unexpectedError
            return .none
        }
        return .task(Task {
            .deleteListResult(
                await dependencies.useCase.deleteList(list.documentId)
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
    
    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.viewModel.listsSection.rows.contains(
            where: { $0 is EmptyRow }
        ) else {
            return .none
        }
        state.viewState = .addingList
        state.viewModel.listsSection.rows.append(EmptyRow())
        return .none
    }
    
    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.listsSection.rows.removeAll { $0 is EmptyRow }
        return .none
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String
    ) -> Effect<Action> {
        return .task(Task {
            .addListResult(
                await dependencies.useCase.addList(
                    name: newListName
                )
            )
        })
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
    
    func onToggleListResult(
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
            state.viewModel.listsSection.rows.removeAll { $0 is EmptyRow }
            state.viewModel.listsSection.rows.append(list)
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
}
