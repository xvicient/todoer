import SwiftUI
import Combine
import ThemeAssets

// MARK: - TDList

public struct TDListView: View {
    enum Tab: String, CaseIterable {
        case add = "Add"
        case sort = "Sort"
        case all = "All"
        case shared = "Shared"
        case invitations = "Invitations"
    }
    
    @State private var activeTab: Tab = .all
    @Namespace private var animation
    @State private var minY: CGFloat = 0.0
    
    private let searchbarThreshold: CGFloat = 50.0
    @Binding private var searchText: String
    private var isSearchFocused: FocusState<Bool>.Binding
    private var hasBackButton: Bool
    
    @FocusState private var isSearching: Bool
    private var headerAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.8)
    private var headerHeight: CGFloat = 150.0

    private let sections: () -> AnyView
    
    @State private var animateGradient = false
    @State private var isScrolling = false

    public init(
        @ViewBuilder sections: @escaping () -> AnyView,
        searchText: Binding<String>,
        isSearchFocused: FocusState<Bool>.Binding,
        hasBackButton: Bool = false
    ) {
        self.sections = sections
        self._searchText = searchText
        self.isSearchFocused = isSearchFocused
        self.hasBackButton = hasBackButton
    }

    public var body: some View {
        ZStack {
            headerBackground()
            .zIndex(0)
            list()
            .zIndex(1)
        }
    }
    
    @ViewBuilder
    fileprivate func headerBackground() -> some View {
        ZStack {
            LinearGradient(colors: [.gray, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(animateGradient ? 45 : 0))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            Color.white
                .safeAreaPadding(.top, headerHeight)
                .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
        }
    }
    
    @ViewBuilder
    fileprivate func list() -> some View {
        ScrollViewReader { proxy in
            List {
                sections()
            }
            .onScrollPhaseChange { _, newPhase, context in
                isScrolling = newPhase.isScrolling
                DispatchQueue.main.async {
                    guard !isSearching else { return }
                    let offset = context.geometry.contentOffset.y + context.geometry.contentInsets.top
                    
                    if offset < searchbarThreshold {
                        withAnimation(headerAnimation) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y + $0.contentInsets.top
            } action: { _, offset in
                guard !isSearching else { return }
                DispatchQueue.main.async {
                    if abs(offset) == .zero {
                        withAnimation(headerAnimation) {
                            minY = 0
                        }
                    } else if -offset > -searchbarThreshold {
                        minY = -offset
                    } else {
                        minY = -searchbarThreshold
                    }
                }
            }
            .onChange(of: isSearching) {
                guard isSearching else { return }
                withAnimation(headerAnimation) {
                    proxy.scrollTo(0, anchor: .top)
                } completion: {
                    withAnimation(headerAnimation.delay(0.1)) {
                        minY = 0
                    }
                }
            }
            .simultaneousGesture(DragGesture().onChanged({ _ in
                isSearching = false
            }))
            .removeBounce()
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .safeAreaInset(edge: .top, spacing: 0) {
                header()
            }
        }
    }
    
    @ViewBuilder
    fileprivate func header() -> some View {
        VStack {
            let progress = max(min(-minY / searchbarThreshold, 1), 0)
            
            ZStack {
                VStack {
                    Text("To-do's")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -(30 * progress) - 10)
                        .padding(.leading, hasBackButton ? 10 * progress : 0)
                    Spacer()
                }
                .zIndex(1)
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                        
                        TextField("Search", text: $searchText)
                            .focused($isSearching)
                            .disabled(isScrolling)
                        
                        if isSearching {
                            Button(action: {
                                isSearching = false
                                searchText = ""
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                            })
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                        }
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15 - (progress * 13))
                    .frame(height: 45)
                    .clipShape(.capsule)
                    .background {
                        RoundedRectangle(cornerRadius: 25 - (progress * 25))
                            .fill(.background)
                            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                            .padding(.top, -progress * 120)
                            .padding(.bottom, -progress * searchbarThreshold)
                            .padding(.horizontal, -progress * 15)
                    }
                    .padding(.top, -(progress * 18))
                    
                    /// Custom Segmented Picker
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(Tab.allCases, id: \.rawValue) { tab in
                                Button(action: {
                                    withAnimation(.snappy) {
                                        activeTab = tab
                                    }
                                }) {
                                    tab.content
                                        .font(.callout)
                                        .foregroundStyle(activeTab == tab ? .white : .black)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 15)
                                        .background {
                                            if activeTab == tab {
                                                Capsule()
                                                    .fill(Color.primary)
                                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                            } else {
                                                Capsule()
                                                    .fill(.background)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, -(progress * 18))
                    .frame(height: 50)
                }
                .padding(.top, 30 + minY)
                .zIndex(0)
            }
            .safeAreaPadding(.horizontal, 15)
        }
        .frame(height: headerHeight)
    }
}

fileprivate extension TDListView.Tab {
    @ViewBuilder
    var content: some View {
        switch self {
        case .add: return Text(Image.plusCircleFill)
        case .sort: return Text(Image.arrowUpArrowDownCircleFill)
        default: return Text(rawValue)
        }
    }
}

fileprivate struct ListNoBounceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
    }
}

fileprivate extension View {
    func removeBounce() -> some View {
        modifier(ListNoBounceModifier())
    }
}

#Preview {
    TDListView(
        sections: {
            AnyView(
                ForEach(0..<20, id: \.self) { n in
                    HStack(spacing: 12) {
                        Circle()
                            .frame(width: 55, height: 55)
                            .overlay(
                                Text("\(n)")
                            )
                        
                        VStack(alignment: .leading, spacing: 6, content: {
                            Rectangle()
                                .frame(width: 140, height: 8)
                            
                            Rectangle()
                                .frame(height: 8)
                            
                            Rectangle()
                                .frame(width: 80, height: 8)
                        })
                    }
                    .id(n)
                    .foregroundStyle(.gray.opacity(0.4))
                    .padding(.horizontal, 5)
                }
            )
        },
        searchText: .constant(""),
        isSearchFocused: FocusState<Bool>().projectedValue
    )
}
