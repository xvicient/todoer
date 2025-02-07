import CoordinatorContract

/// A mock implementation of CoordinatorApi for testing purposes
/// This class tracks method calls and provides flags to verify interactions
public final class CoordinatorMock: CoordinatorApi {
    /// Flag indicating whether a user is logged in
    public var isUserLogged: Bool = false    
    
    /// Creates a new instance of the mock coordinator
    public init() {}

    // MARK: - CoordinatorApi

    /// Simulates logging out a user
    /// Sets isLoggOutCalled to true
    public func loggOut() {
        isLoggOutCalled = true
    }

    /// Simulates logging in a user
    /// Sets isLoggInCalled to true
    public func loggIn() {
        isLoggInCalled = true
    }

    /// Simulates pushing a page onto the navigation stack
    /// - Parameter page: The page to push (no-op in mock)
    public func push(_ page: Page) {}

    /// Simulates presenting a sheet
    /// - Parameter sheet: The sheet to present (no-op in mock)
    public func present(sheet: Sheet) {}

    /// Simulates presenting a full-screen cover
    /// - Parameter fullScreenCover: The full-screen cover to present (no-op in mock)
    public func present(fullScreenCover: FullScreenCover) {}

    /// Simulates popping the current page (no-op in mock)
    public func pop() {}

    /// Simulates popping to root page (no-op in mock)
    public func popToRoot() {}

    /// Simulates dismissing the current sheet
    /// Sets isDismissSheetCalled to true
    public func dismissSheet() {
        isDismissSheetCalled = true
    }

    // MARK: - TestCoordinator

    /// Flag indicating whether loggOut() was called
    public var isLoggOutCalled = false

    /// Flag indicating whether loggIn() was called
    public var isLoggInCalled = false

    /// Flag indicating whether dismissSheet() was called
    public var isDismissSheetCalled = false
}
