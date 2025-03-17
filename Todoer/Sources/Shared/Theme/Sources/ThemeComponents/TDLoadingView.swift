import SwiftUI

@MainActor
public final class TDLoadingModel: ObservableObject {
    @Published var isLoading: Bool = true
    
    public init() {}
    
    public func show(_ show: Bool) {
        isLoading = show
    }
}

public struct TDLoadingView: View {
    
    public init() {}
    
    public var body: some View {
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

fileprivate struct TDLoadingOpacityModifier: ViewModifier {
    @EnvironmentObject var loading: TDLoadingModel
    var isHidden: Bool = false
    
    func body(content: Content) -> some View {
        content
            .opacity(loading.isLoading ? 1.0 : 0.0)
            .zIndex(1)
            .allowsHitTesting(loading.isLoading)
            .if(isHidden) {
                $0.hidden()
            }
            .animation(
                .easeInOut(duration: 0.5).delay(0.5),
                value: loading.isLoading
            )
    }
}

public extension View {
    func loadingOpacity(isHidden: Bool) -> some View {
        modifier(TDLoadingOpacityModifier(isHidden: isHidden))
    }
}
