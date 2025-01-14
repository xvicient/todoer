import SwiftUI
import Data
import CoordinatorContract
import FeatureProviderContract

@MainActor
final class Coordinator: CoordinatorApi, ObservableObject {

	@Published var path = NavigationPath()
	@Published var sheet: Sheet?
	@Published var fullScreenCover: FullScreenCover?
	@Published var landingView: AnyView?
	@Published var landingPage: Page
    private let featureProvider: FeatureProviderAPI

    init(
        authenticationService: AuthenticationService = AuthenticationService(),
        featureProvider: FeatureProviderAPI
    ) {
        self.featureProvider = featureProvider
        landingPage = authenticationService.isUserLogged ? .home : .authentication
        landingView = build(page: landingPage)
    }

	@MainActor
	func loggOut() {
		landingPage = .authentication
		landingView = build(page: .authentication)
	}

	@MainActor
	func loggIn() {
		landingPage = .home
		landingView = build(page: .home)
	}

	func push(_ page: Page) {
		path.append(page)
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
	func build(page: Page) -> AnyView {
		AnyView(_build(page: page))
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
		}
	}
}
