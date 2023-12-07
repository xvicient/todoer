import SwiftUI

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
        .environmentObject(coordinator)
    }
}

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorView()
    }
}
