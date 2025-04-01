import SwiftUI
import Combine
import ThemeAssets
import Strings

// MARK: - TDList

public struct TDListView: View {
    
    public enum SlideDirection {
        case forward
        case backward
        
        var transition: AnyTransition {
            switch self {
            case .forward:
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
            case .backward:
                    .asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    )
            }
        }
    }
    
    public struct Configuration {
        let title: String
        let tabs: [TDListTab]
        let activeTab: Binding<TDListTab>
        let searchText: Binding<String>
        @Binding var isSearchFocused: Bool
        
        public init(
            title: String,
            tabs: [TDListTab],
            activeTab: Binding<TDListTab>,
            searchText: Binding<String>,
            isSearchFocused: Binding<Bool>
        ) {
            self.title = title
            self.tabs = tabs
            self.activeTab = activeTab
            self.searchText = searchText
            self._isSearchFocused = isSearchFocused
        }
    }
    
    /// init properties
    private let listContent: () -> TDListContentView
    private let configuration: Configuration
    @Binding private var searchText: String
    @FocusState private var isSearchFocused: Bool
    @Binding private var activeTab: TDListTab
    
    /// Animation properties
    @State private var slideDirection: SlideDirection = .forward
    private let headerAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.8)
    
    /// Scrolling properties
    @State private var isScrolling = false
    private let primaryThreshold: CGFloat = 55.0
    private let secondaryThreshold: CGFloat = 90.0
    @State private var primaryScrollOffset: CGFloat = 0.0
    @State private var secondaryScrollOffset: CGFloat = 0.0
    private let headerHeight: CGFloat = 150.0
    
    /// Toolbar  properties
    @Environment(\.presentationMode) private var presentationMode
    private var hasBackButton: Bool {
        presentationMode.wrappedValue.isPresented
    }
    
    public init(
        configuration: Configuration,
        @ViewBuilder content: @escaping () -> TDListContentView
    ) {
        self.listContent = content
        self.configuration = configuration
        self._searchText = configuration.searchText
        self._activeTab = configuration.activeTab
        self.isSearchFocused = configuration.isSearchFocused
    }
    
    public var body: some View {
        ZStack {
            list
                .id(activeTab.rawValue)
                .transition(slideDirection.transition)
            header()
        }
        .background(background)
    }
}

// MARK: - TDListView ViewBuilders

extension TDListView {
    @ViewBuilder
    fileprivate var background: some View {
        VStack {
            Color(.lightGray)
                .ignoresSafeArea(edges: .all)
                .frame(height: headerHeight)
            Color.white
                .safeAreaPadding(.top, headerHeight)
                .ignoresSafeArea(edges: .all)
        }
    }
    
    @ViewBuilder
    fileprivate var list: some View {
        ScrollViewReader { proxy in
            List {
                listContent()
            }
            .onScrollPhaseChange { _, newPhase, context in
                isScrolling = newPhase.isScrolling
                DispatchQueue.main.async {
                    guard !isSearchFocused else { return }
                    let offset = context.geometry.contentOffset.y + context.geometry.contentInsets.top
                    
                    if offset < primaryThreshold {
                        withAnimation(headerAnimation) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y + $0.contentInsets.top
            } action: { _, offset in
                guard !isSearchFocused else { return }
                DispatchQueue.main.async {
                    secondaryScrollOffset = -offset > -secondaryThreshold ? -offset : -secondaryThreshold
                    
                    if abs(offset) == .zero {
                        withAnimation(headerAnimation) {
                            primaryScrollOffset = 0
                        }
                    } else if -offset > -primaryThreshold {
                        primaryScrollOffset = -offset
                    } else {
                        primaryScrollOffset = -primaryThreshold
                    }
                }
            }
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                withAnimation(headerAnimation) {
                    proxy.scrollTo(0, anchor: .top)
                } completion: {
                    withAnimation(headerAnimation.delay(0.1)) {
                        primaryScrollOffset = 0
                        secondaryScrollOffset = 0
                    }
                }
            }
            .simultaneousGesture(DragGesture().onChanged({ _ in
                isSearchFocused = false
            }))
            .removeBounce()
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: headerHeight)
            }
        }
    }
    
    @ViewBuilder
    fileprivate func header() -> some View {
        VStack {
            ZStack {
                let scrollProgress = max(min(-primaryScrollOffset / primaryThreshold, 1), 0)
                
                let tabBarHeight = (headerHeight + (secondaryScrollOffset*2)) < 0 ? 0 : (headerHeight + (secondaryScrollOffset*2))
                let contentHeight = -primaryScrollOffset < primaryThreshold ? headerHeight : headerHeight - (primaryScrollOffset-secondaryScrollOffset)
                
                let cornerRadius = 25 - (scrollProgress * 25)
                let horizontalPadding = 15 - (scrollProgress * 13)
                let searchBarHeight: CGFloat = 45
                
                TDListTabButtonView(
                    slideDirection: $slideDirection,
                    activeTab: $activeTab,
                    tabs: configuration.tabs
                )
                .padding(.bottom, 5)
                .frame(height: tabBarHeight, alignment: .bottomLeading)
                
                VStack {
                    HStack(spacing: 12) {
                        Image.mag
                            .font(.title3)
                        
                        TextField(Strings.List.searchPlaceholder, text: $searchText)
                            .focused($isSearchFocused)
                            .disabled(isScrolling)
                        
                        if isSearchFocused {
                            Button(action: {
                                isSearchFocused = false
                                searchText = ""
                            }, label: {
                                Image.xmark
                                    .font(.title3)
                            })
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .frame(height: searchBarHeight)
                    .clipShape(.capsule)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.background)
                            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                            .padding(.top, -scrollProgress * headerHeight)
                            .padding(.bottom, -scrollProgress * 10)
                            .padding(.horizontal, -scrollProgress * 15)
                    }
                }
                .padding(.bottom, 65)
                .frame(height: contentHeight, alignment: .bottomLeading)
                
                TDExpandableText(text: configuration.title, limit: 1)
                    .padding(.bottom, 120)
                    .frame(height: contentHeight, alignment: .bottomLeading)
                    .safeAreaPadding(.leading, hasBackButton ? 15 : 0)
            }
            .safeAreaPadding(.horizontal, 15)
            Spacer()
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
    struct RowMock: TDListRow {
        var id = UUID()
        var done = false
        var name = "List 1"
        var index = 0
        var image = Image.circle
        var leadingActions = [TDListSwipeAction]()
        var trailingActions = [TDListSwipeAction]()
        var isEditing = false
    }
    
    return TDListView(
        configuration: .init(
            title: "To-do's",
            tabs: TDListTab.allCases,
            activeTab: .constant(.all),
            searchText: .constant(""),
            isSearchFocused: .constant(true)
        )
    ) {
        TDListContentView(
            configuration: .init(
                isMoveEnabled: false,
                isSwipeEnabled: false,
                listHeight: 100
            ),
            actions: .init(
                onSubmit: { _, _ in },
                onCancel: {},
                onSwipe: { _, _ in },
                onMove: { _, _ in }
            ),
            rows: .constant(Array(repeating: RowMock(), count: 20)),
            editMode: .constant(.inactive)
        )
    }
}
