import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    @State private var shareListDetent = PresentationDetent.medium
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.landingView
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                        .setupNavigationBar()
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
                .setupNavigationBar()
        }
        .onAppear {
            coordinator.start()
        }
        .colorScheme(.light)
        .preferredColorScheme(.dark)
    }
}

// MARK: - NavigationBarModifier

struct NavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
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

private extension View {
    func setupNavigationBar() -> some View {
        modifier(NavigationBarModifier())
    }
}

// MARK: - CoordinatorView_Previews

struct CoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatorView()
    }
}
