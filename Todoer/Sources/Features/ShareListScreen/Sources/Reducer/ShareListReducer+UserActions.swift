import Application

/// Extension handling user-initiated actions in the ShareList reducer
extension ShareList.Reducer {
    /// Handles tapping the share button
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - email: Email of the user to share with
    ///   - owner: Name of the list owner
    /// - Returns: An effect that initiates the share operation
    func onDidTapShareButton(
        state: inout State,
        email: String,
        owner: String
    ) -> Effect<Action> {
        var ownerName = ""
        if let selfName = state.viewModel.selfName {
            ownerName = selfName
        } else {
            ownerName = owner
        }
        
        return .task { send in
            await send(
                .shareListResult(
                    useCase.shareList(
                        shareEmail: email,
                        ownerName: ownerName,
                        list: dependencies.list
                    )
                )
            )
        }
    }

    /// Handles dismissing an error alert
    /// - Parameter state: Current state of the reducer
    /// - Returns: No effect is produced
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
