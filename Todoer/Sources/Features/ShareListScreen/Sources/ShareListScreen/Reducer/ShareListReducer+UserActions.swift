import Application

// MARK: - Reducer user actions

extension ShareList.Reducer {
	func onDidTapShareButton(
		state: inout State,
		email: String,
        owner: String
	) -> Effect<Action> {
		return .task { send in
			await send(
				.shareListResult(
					dependencies.useCase.shareList(
						shareEmail: email,
                        owner: owner,
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
