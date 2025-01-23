import SwiftUI
import Data
import CoordinatorContract

@MainActor
final class Coordinator: CoordinatorApi, ObservableObject {

	@Published var path = NavigationPath()
	@Published var sheet: Sheet?
	@Published var fullScreenCover: FullScreenCover?
	@Published var landingView: AnyView?
	@Published var landingScreen: Screen
    private let authenticationService: AuthenticationService
    private let featureProvider: FeatureProviderAPI
    public var isUserLogged: Bool {
        authenticationService.isUserLogged
    }

    init(
        authenticationService: AuthenticationService = AuthenticationService(),
        featureProvider: FeatureProviderAPI
    ) {
        self.authenticationService = authenticationService
        self.featureProvider = featureProvider
        landingScreen = authenticationService.isUserLogged ? .home : .authentication
        landingView = build(screen: landingScreen)
    }

	@MainActor
	func loggOut() {
        landingScreen = .authentication
		landingView = build(screen: .authentication)
	}

	@MainActor
	func loggIn() {
        landingScreen = .home
		landingView = build(screen: .home)
	}

	func push(_ screen: Screen) {
		path.append(screen)
	}

	func present(sheet: Sheet) {
		self.sheet = sheet
	}

	func present(fullScreenCover: FullScreenCover) {
		self.fullScreenCover = fullScreenCover
	}

	func pop() {
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count)
	}

	func dismissSheet() {
		self.sheet = nil
	}

	func dismissFullScreenCover() {
		self.fullScreenCover = nil
	}

	@MainActor @ViewBuilder
	func build(screen: Screen) -> AnyView {
		AnyView(_build(screen: screen))
	}

	@MainActor @ViewBuilder
	func build(sheet: Sheet) -> some View {
		switch sheet {
		case .shareList(let list):
			NavigationStack {
                AnyView(featureProvider.makeShareListScreen(coordinator: self, list: list))
			}
		}
	}

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

extension Coordinator {
	@MainActor @ViewBuilder
	fileprivate func _build(screen: Screen) -> some View {
		switch screen {
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
