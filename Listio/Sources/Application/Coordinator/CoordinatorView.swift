import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    @State private var shareListDetent = PresentationDetent.medium
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.landingView
                .setupNavigationBar(page: coordinator.landingPage)
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                        .setupNavigationBar(page: page)
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
        .colorScheme(.light)
        .preferredColorScheme(.dark)
    }
}

// MARK: - NavigationBarModifier

struct NavigationBarModifier: ViewModifier {
    var page: Page
    
    func body(content: Content) -> some View {
        if page == .authentication {
            content
        } else {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.backgroundPrimary)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image.launchScreen
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    }
                }
        }
    }
}

private extension View {
    func setupNavigationBar(page: Page) -> some View {
        modifier(NavigationBarModifier(page: page))
    }
}

// MARK: - CoordinatorView_Previews

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorView()
    }
}
