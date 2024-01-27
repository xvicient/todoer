// MARK: - Reducer user actions

@MainActor
internal extension ShareList.Reducer {
    func onDidTapShareButton(
        state: inout State,
        email: String
    ) -> Effect<Action> {
        return .task(Task {
            .shareListResult(
                await dependencies.useCase.shareList(
                    shareEmail: email,
                    list: dependencies.list
                )
            )
        })
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
