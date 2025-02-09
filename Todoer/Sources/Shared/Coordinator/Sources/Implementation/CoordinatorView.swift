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
        ZStack {
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
            .zIndex(0)
            .preferredColorScheme(.light)
            LoadingView()
                .loadingOpacity(coordinator: coordinator)
        }
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
    
    fileprivate func loadingOpacity(coordinator: Coordinator) -> some View {
        modifier(LoadingOpacityModifier(coordinator: coordinator))
    }
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}

fileprivate struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .zIndex(0)
            Image.todoer
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 35)
                .zIndex(1)
        }
    }
}

fileprivate struct LoadingOpacityModifier: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    func body(content: Content) -> some View {
        content
            .opacity(coordinator.isLoading ? 1.0 : 0.0)
            .zIndex(1)
            .allowsHitTesting(coordinator.isLoading)
            .if(coordinator.landingScreen != .home) {
                $0.hidden()
            }
            .animation(
                .easeInOut(duration: 0.5),
                value: coordinator.isLoading
            )
    }
}

//fileprivate struct LoadingOpacityModifier: ViewModifier {
//    @ObservedObject var coordinator: Coordinator
//    @State private var hideAfterDelay = false
//    
//    func body(content: Content) -> some View {
//        content
//            .opacity(hideAfterDelay ? 0 : 1)
//            .animation(.easeInOut(duration: 0.5), value: hideAfterDelay)
//            .onChange(of: coordinator.isLoading) {
//                if coordinator.isLoading {
//                    // Immediately show without animation
//                    hideAfterDelay = false
//                } else {
//                    // Start 2-second delay before animating out
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        hideAfterDelay = true
//                    }
//                }
//            }
//            .onAppear {
//                // Reset state when view reappears
//                hideAfterDelay = !coordinator.isLoading
//            }
//    }
//}
