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
            
        case (.loading, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (_, .getPhotoUrlResult):
            return .none
        
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
