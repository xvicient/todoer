import Combine
import Application

// MARK: - View appear

extension AppMenu.Reducer {
	func onAppear(
		state: inout State
	) -> Effect<Action> {
		return .task { send in
			await send(
				.getPhotoUrlResult(
					useCase.getPhotoUrl()
				)
			)
		}
	}
}
