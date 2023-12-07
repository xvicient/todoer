import SwiftUI

enum Page: Hashable, Identifiable, Equatable {
    case authentication
    case home
    case products(ListModel)
    
    var id: Self { self }
}

enum Sheet: Hashable, Identifiable {
    case shareList
    
    var id: Self { self }
}

enum FullScreenCover: Hashable, Identifiable {
    case home
    
    var id: Self { self }
}

class Coordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    private var authenticationService: AuthenticationService
    
    init(authenticationService: AuthenticationService = AuthenticationService()) {
        self.authenticationService = authenticationService
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
    func buildLandingPage() -> some View {
        build(page: landingPage)
    }
    
    @MainActor @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .authentication:
            AuthenticationBuilder.makeAuthentication()
        case .home:
            HomeBuilder.makeHome()
        case let .products(list):
            ProductsBuilder.makeProductList(list: list)
        }
    }
    
    @MainActor @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
        case .shareList:
            NavigationStack {
                EmptyView()
            }
        }
    }
    
    @MainActor @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .home:
            NavigationStack {
                HomeBuilder.makeHome()
            }
        }
    }
}

private extension Coordinator {
    var landingPage: Page {
        do {
            _ = try authenticationService.getAuthenticatedUser()
            return .home
        } catch {
            return .authentication
        }
    }
}
