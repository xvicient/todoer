import xRedux

// MARK: - View appear

extension ShareList.Reducer {
	func onAppear(
		state: inout State
	) -> Effect<Action> {
		.task { send in
			await send(
				.fetchDataResult(
					useCase.fetchData(
						uids: dependencies.list.uid
					)
				)
			)
		}
	}
}
