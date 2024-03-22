import SwiftUI

@testable import Presentation

final class TestCoordinator: CoordinatorApi {

	// MARK: - CoordinatorApi

	func loggOut() {
		isLoggOutCalled = true
	}

	func loggIn() {
		isLoggInCalled = true
	}

	func push(_ page: Presentation.Page) {}

	func present(sheet: Presentation.Sheet) {}

	func present(fullScreenCover: Presentation.FullScreenCover) {}

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
