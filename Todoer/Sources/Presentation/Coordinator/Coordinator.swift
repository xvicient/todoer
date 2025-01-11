import SwiftUI
import Data
import AuthenticationScreen

enum Page: Hashable, Identifiable {
	case authentication
	case home
	case listItems(UserList)
	case about

	var id: Self { self }
}

enum Sheet: Hashable, Identifiable {
	case shareList(UserList)

	var id: Self { self }
}

enum FullScreenCover: Hashable, Identifiable {
	case home

	var id: Self { self }
}

@MainActor
protocol CoordinatorApi {
	func loggOut()
	func loggIn()
	func push(_ page: Page)
	func present(sheet: Sheet)
	func present(fullScreenCover: FullScreenCover)
	func pop()
	func popToRoot()
	func dismissSheet()
}

@MainActor
final class Coordinator: CoordinatorApi, ObservableObject {

	@Published var path = NavigationPath()
	@Published var sheet: Sheet?
	@Published var fullScreenCover: FullScreenCover?
	@Published var landingView: AnyView?
	@Published var landingPage: Page

	init(authenticationService: AuthenticationService = AuthenticationService()) {
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
				ShareList.Builder.makeShareList(
					coordinator: self,
					list: list
				)
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
			Authentication.Builder.makeAuthentication(
//				coordinator: self
			)
		case .home:
			Home.Builder.makeHome(
				coordinator: self
			)
		case let .listItems(list):
			ListItems.Builder.makeItemsList(
				list: list
			)
		case .about:
			About.Builder.makeAbout()
		}
	}
}
