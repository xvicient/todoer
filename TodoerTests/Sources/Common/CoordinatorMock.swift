import SwiftUI
import CoordinatorContract

final class CoordinatorMock: CoordinatorApi {

	// MARK: - CoordinatorApi

	func loggOut() {
		isLoggOutCalled = true
	}

	func loggIn() {
		isLoggInCalled = true
	}

	func push(_ page: Page) {}

	func present(sheet: Sheet) {}

	func present(fullScreenCover: FullScreenCover) {}

	func pop() {}

	func popToRoot() {}

	func dismissSheet() {
		isDismissSheetCalled = true
	}

	// MARK: - TestCoordinator

	var isLoggOutCalled = false

	var isLoggInCalled = false

	var isDismissSheetCalled = false
}
