import SwiftUI

enum Page: Hashable, Identifiable, Equatable {
    case authentication
    case home
    case listItems(List)
    
    var id: Self { self }
}

enum Sheet: Hashable, Identifiable {
    case shareList(List)
    
    var id: Self { self }
}

enum FullScreenCover: Hashable, Identifiable {
    case home
    
    var id: Self { self }
}

final class Coordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published var landingView: AnyView?
    private var landingPage: Page
    
    init(authenticationService: AuthenticationService = AuthenticationService()) {
        landingPage = authenticationService.isUserLogged ? .home : .authentication
    }
    
    @MainActor
    func start() {
        landingView = build(page: landingPage)
    }
    
    @MainActor
    func loggOut() {
        landingView = build(page: .authentication)
    }
    
    @MainActor
    func loggIn() {
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
        AnyView(get(page: page))
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

private extension Coordinator {
    @MainActor @ViewBuilder
    func get(page: Page) -> some View {
        switch page {
        case .authentication:
            Authentication.Builder.makeAuthentication(
                coordinator: self
            )
        case .home:
            Home.Builder.makeHome(
                coordinator: self
            )
        case let .listItems(list):
            ListItems.Builder.makeItemsList(
                list: list
            )
        }
    }
}
