import SwiftUI

enum Page: Hashable, Identifiable, Equatable {
    case authentication
    case home
    case products(List)
    
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
    
    @Published private var landingPage: Page?
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    init(authenticationService: AuthenticationService = AuthenticationService()) {
        landingPage = authenticationService.isUserLogged ? .home : .authentication
    }
    
    func loggOut() {
        landingPage = .authentication
    }
    
    func loggIn() {
        landingPage = .home
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
        if let page = landingPage {
            build(page: page)
        }
    }
    
    @MainActor @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .authentication:
            Authentication.Builder.makeAuthentication(coordinator: self)
        case .home:
            HomeBuilder.makeHome()
        case let .products(list):
            ListItemsBuilder.makeProductList(list: list)
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

struct CoordinatorView: View {
    
    @StateObject private var coordinator = Coordinator()
    @State private var shareListDetent = PresentationDetent.medium
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.buildLandingPage()
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    switch sheet {
                    case .shareList:
                        coordinator.build(sheet: sheet)
                            .presentationDetents(
                                [shareListDetent, .large],
                                selection: $shareListDetent
                            )
                    }
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { fullScreenCover in
                    coordinator.build(fullScreenCover: fullScreenCover)
                }
        }
        .environmentObject(coordinator) // TODO: - to remove once all the features are migrated to redux
    }
}

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorView()
    }
}
