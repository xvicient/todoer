import SwiftUI
import ThemeAssets
import CoordinatorContract

/// The main view container that manages navigation and presentation in the app
/// Uses a coordinator to handle navigation logic and state
public struct CoordinatorView: View {
    /// The coordinator object that manages navigation state and logic
    @StateObject private var coordinator: Coordinator
    /// The menu view that appears in the navigation bar
    private let menuView: AnyView
    
    /// Creates a new coordinator view
    /// - Parameter featureProvider: Provider for creating feature-specific views
    public init(featureProvider: FeatureProviderAPI) {
        let coordinator = Coordinator(featureProvider: featureProvider)
        _coordinator = StateObject(wrappedValue: coordinator)
        menuView = coordinator.build(page: .menu)
    }

    /// The body of the view that sets up the navigation stack and presentation logic
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.landingView
                .setupNavigationBar(page: coordinator.landingPage)
                .if(coordinator.isUserLogged) {
                    $0.navigationBarItems(
                        leading: menuView
                    )
                }
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                        .setupNavigationBar(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    switch sheet {
                    case .shareList:
                        coordinator.build(sheet: sheet)
                            .presentationDetents(
                                [.height(350)]
                            )
                    }
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { fullScreenCover in
                    coordinator.build(fullScreenCover: fullScreenCover)
                }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - NavigationBarModifier

/// A view modifier that configures the navigation bar appearance based on the current page
struct NavigationBarModifier: ViewModifier {
    /// The current page being displayed
    var page: Page

    /// Applies the navigation bar styling based on the current page
    func body(content: Content) -> some View {
        if page == .authentication {
            content
        }
        else {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.backgroundWhite)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image.todoer
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: /*@START_MENU_TOKEN@*/ 100 /*@END_MENU_TOKEN@*/)
                    }
                }
        }
    }
}

/// Extension providing navigation bar setup functionality to View
extension View {
    /// Applies the navigation bar modifier with the specified page
    /// - Parameter page: The current page to configure the navigation bar for
    /// - Returns: A view with the navigation bar configured
    fileprivate func setupNavigationBar(page: Page) -> some View {
        modifier(NavigationBarModifier(page: page))
    }
}

/// Extension to customize the back button appearance in UINavigationController
extension UINavigationController {
    /// Configures the back button to use minimal display mode
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
