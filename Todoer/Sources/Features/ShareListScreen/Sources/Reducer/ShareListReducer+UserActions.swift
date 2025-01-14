import Application

// MARK: - Reducer user actions

extension ShareList.Reducer {
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

	func onDidTapDismissError(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
	}
}
