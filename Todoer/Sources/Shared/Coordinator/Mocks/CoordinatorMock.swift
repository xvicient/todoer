import CoordinatorContract

public final class CoordinatorMock: CoordinatorApi {
    
    public init() {}

	// MARK: - CoordinatorApi

    public func loggOut() {
		isLoggOutCalled = true
	}

    public func loggIn() {
		isLoggInCalled = true
	}

    public func push(_ page: Page) {}

    public func present(sheet: Sheet) {}

    public func present(fullScreenCover: FullScreenCover) {}

    public func pop() {}

    public func popToRoot() {}

    public func dismissSheet() {
		isDismissSheetCalled = true
	}

	// MARK: - TestCoordinator

    public var isLoggOutCalled = false

    public var isLoggInCalled = false

    public var isDismissSheetCalled = false
}
