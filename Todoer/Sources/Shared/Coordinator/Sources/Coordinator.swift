import SwiftUI
import Data
import CoordinatorContract

/// Main coordinator class responsible for managing navigation and view presentation in the app
/// Conforms to CoordinatorApi for navigation control and ObservableObject for SwiftUI binding
@MainActor
final class Coordinator: CoordinatorApi, ObservableObject {

    /// The navigation path representing the current navigation stack
    @Published var path = NavigationPath()
    /// The currently presented sheet, if any
    @Published var sheet: Sheet?
    /// The currently presented full-screen cover, if any
    @Published var fullScreenCover: FullScreenCover?
    /// The landing view to be shown when the app starts
    @Published var landingView: AnyView?
    /// The current landing page type
    @Published var landingPage: Page
    /// Service handling authentication-related operations
    private let authenticationService: AuthenticationService
    /// Provider for creating feature-specific views
    private let featureProvider: FeatureProviderAPI
    /// Flag indicating whether a user is currently logged in
    public var isUserLogged: Bool {
        authenticationService.isUserLogged
    }

    /// Creates a new coordinator instance
    /// - Parameters:
    ///   - authenticationService: Service for handling authentication (defaults to new instance)
    ///   - featureProvider: Provider for creating feature-specific views
    init(
        authenticationService: AuthenticationService = AuthenticationService(),
        featureProvider: FeatureProviderAPI
    ) {
        self.authenticationService = authenticationService
        self.featureProvider = featureProvider
        landingPage = authenticationService.isUserLogged ? .home : .authentication
        landingView = build(page: landingPage)
    }

    /// Sets the landing page to authentication and updates the landing view
    @MainActor
    func loggOut() {
        landingPage = .authentication
        landingView = build(page: .authentication)
    }

    /// Sets the landing page to home and updates the landing view
    @MainActor
    func loggIn() {
        landingPage = .home
        landingView = build(page: .home)
    }

    /// Pushes a new page onto the navigation stack
    /// - Parameter page: The page to push
    func push(_ page: Page) {
        path.append(page)
    }

    /// Presents a sheet modally
    /// - Parameter sheet: The sheet to present
    func present(sheet: Sheet) {
        self.sheet = sheet
    }

    /// Presents a full-screen cover
    /// - Parameter fullScreenCover: The full-screen cover to present
    func present(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }

    /// Removes the last page from the navigation stack
    func pop() {
        path.removeLast()
    }

    /// Removes all pages from the navigation stack
    func popToRoot() {
        path.removeLast(path.count)
    }

    /// Dismisses the currently presented sheet
    func dismissSheet() {
        self.sheet = nil
    }

    /// Dismisses the currently presented full-screen cover
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }

    /// Builds a view for a given page type
    /// - Parameter page: The page type to build
    /// - Returns: The built view wrapped in AnyView
    @MainActor @ViewBuilder
    func build(page: Page) -> AnyView {
        AnyView(_build(page: page))
    }

    /// Builds a view for a given sheet type
    /// - Parameter sheet: The sheet type to build
    /// - Returns: The built view wrapped in a NavigationStack
    @MainActor @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
        case .shareList(let list):
            NavigationStack {
                AnyView(featureProvider.makeShareListScreen(coordinator: self, list: list))
            }
        }
    }

    /// Builds a view for a given full-screen cover type
    /// - Parameter fullScreenCover: The full-screen cover type to build
    /// - Returns: The built view wrapped in a NavigationStack
    @MainActor @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .home:
            NavigationStack {
                EmptyView()
            }
        }
    }
}

/// Private extension containing the actual view building logic
extension Coordinator {
    /// Internal method to build views for different page types
    /// - Parameter page: The page type to build
    /// - Returns: The appropriate view for the given page type
    @MainActor @ViewBuilder
    fileprivate func _build(page: Page) -> some View {
        switch page {
        case .authentication:
            AnyView(featureProvider.makeAuthenticationScreen(coordinator: self))
        case .home:
            AnyView(featureProvider.makeHomeScreen(coordinator: self))
        case let .listItems(list):
            AnyView(featureProvider.makeListItemsScreen(list: list))
        case .about:
            AnyView(featureProvider.makeAboutScreen())
        case .menu:
            AnyView(featureProvider.makeAppMenuView(coordinator: self))
        }
    }
}
