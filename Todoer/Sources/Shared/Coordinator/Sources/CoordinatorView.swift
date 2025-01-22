import SwiftUI
import ThemeAssets
import CoordinatorContract

public struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator
    private let menuView: AnyView
    
    public init(featureProvider: FeatureProviderAPI) {
        let coordinator = Coordinator(featureProvider: featureProvider)
        _coordinator = StateObject(wrappedValue: coordinator)
        menuView = coordinator.build(page: .menu)
    }

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

struct NavigationBarModifier: ViewModifier {
	var page: Page

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

extension View {
	fileprivate func setupNavigationBar(page: Page) -> some View {
		modifier(NavigationBarModifier(page: page))
	}
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
