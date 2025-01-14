import Application

// MARK: - View appear

extension ShareList.Reducer {
	func onAppear(
		state: inout State
	) -> Effect<Action> {
		.task { send in
			await send(
				.fetchUsersResult(
					useCase.fetchUsers(
						uids: dependencies.list.uid
					)
				)
			)
		}
	}
}
