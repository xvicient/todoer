import CoordinatorContract
import SwiftUI
import ThemeAssets

public struct CoordinatorView: View {
    @ObservedObject private var coordinator: Coordinator
    private let menuView: AnyView
    @State private var sheetHeight: CGFloat = 0
    
    public init(coordinator: Coordinator) {
        self.coordinator = coordinator
        menuView = coordinator.build(screen: .menu)
    }

    public var body: some View {
        ZStack {
            NavigationStack(path: $coordinator.path) {
                coordinator.landingView
                    .setupNavigationBar(screen: coordinator.landingScreen)
                    .if(coordinator.isUserLogged) {
                        $0.navigationBarItems(
                            trailing: menuView
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
                                .background(GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            sheetHeight = geometry.size.height
                                        }
                                })
                                .presentationDetents([.height(sheetHeight)])
                                .presentationDragIndicator(.hidden)
                                .id(sheetHeight)
                        }
                    }
                    .fullScreenCover(item: $coordinator.fullScreenCover) { fullScreenCover in
                        coordinator.build(fullScreenCover: fullScreenCover)
                    }
            }
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
                .toolbarBackground(.hidden, for: .navigationBar)
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

fileprivate struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            Image.todoer
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 35)
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
                .easeInOut(duration: 0.5).delay(0.5),
                value: coordinator.isLoading
            )
    }
}


extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
