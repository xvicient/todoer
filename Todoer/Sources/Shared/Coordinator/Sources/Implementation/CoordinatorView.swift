import CoordinatorContract
import SwiftUI
import ThemeAssets

public struct CoordinatorView: View {
    @StateObject private var coordinator: Coordinator
    private let menuView: AnyView

    public init(featureProvider: FeatureProviderAPI) {
        let coordinator = Coordinator(featureProvider: featureProvider)
        _coordinator = StateObject(wrappedValue: coordinator)
        menuView = coordinator.build(screen: .menu)
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.landingView
                .setupNavigationBar(screen: coordinator.landingScreen)
                .if(coordinator.isUserLogged) {
                    $0.navigationBarItems(
                        leading: menuView
                    )
                }
                .navigationDestination(for: Screen.self) { screen in
                    coordinator.build(screen: screen)
                        .setupNavigationBar(screen: screen)
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
    var screen: Screen

    func body(content: Content) -> some View {
        if screen == .authentication {
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
    fileprivate func setupNavigationBar(screen: Screen) -> some View {
        modifier(NavigationBarModifier(screen: screen))
    }
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
