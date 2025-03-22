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
    private let listContent: () -> TDListContent
    private let configuration: Configuration
    @Binding private var searchText: String
    @FocusState private var isSearchFocused: Bool
    @Binding private var activeTab: TDListTab
    
    /// Animation properties
    @State private var slideDirection: SlideDirection = .forward
    private let headerAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.8)
    
    /// Scrolling properties
    @State private var isScrolling = false
    private let headerThreeshold1: CGFloat = 55.0
    private let headerThreeshold2: CGFloat = 90.0
    @State private var threeshold1MinY: CGFloat = 0.0
    @State private var threeshold2MinY: CGFloat = 0.0
    private let headerHeight: CGFloat = 150.0
    
    /// Toolbar  properties
    @Environment(\.presentationMode) private var presentationMode
    private var hasBackButton: Bool {
        presentationMode.wrappedValue.isPresented
    }
    
    public init(
        configuration: Configuration,
        @ViewBuilder content: @escaping () -> TDListContent
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
                    
                    if offset < headerThreeshold1 {
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
                    threeshold2MinY = -offset > -headerThreeshold2 ? -offset : -headerThreeshold2
                    if abs(offset) == .zero {
                        withAnimation(headerAnimation) {
                            threeshold1MinY = 0
                        }
                    } else if -offset > -headerThreeshold1 {
                        threeshold1MinY = -offset
                    } else {
                        threeshold1MinY = -headerThreeshold1
                    }
                }
            }
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                withAnimation(headerAnimation) {
                    proxy.scrollTo(0, anchor: .top)
                } completion: {
                    withAnimation(headerAnimation.delay(0.1)) {
                        threeshold1MinY = 0
                        threeshold2MinY = 0
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
                let progress = max(min(-threeshold1MinY / headerThreeshold1, 1), 0)
                let threeshold1Height = (headerHeight + (threeshold2MinY*2)) < 0 ? 0 : (headerHeight + (threeshold2MinY*2))
                let threeshold2Height = -threeshold1MinY < headerThreeshold1 ? headerHeight : headerHeight - (threeshold1MinY-threeshold2MinY)
                
                TDListTabButtonView(
                    slideDirection: $slideDirection,
                    activeTab: $activeTab,
                    tabs: configuration.tabs
                )
                .padding(.bottom, 5)
                .frame(height: threeshold1Height, alignment: .bottomLeading)
                
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
                    .padding(.horizontal, 15 - (progress * 13))
                    .frame(height: 45)
                    .clipShape(.capsule)
                    .background {
                        RoundedRectangle(cornerRadius: 25 - (progress * 25))
                            .fill(.background)
                            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                            .padding(.top, -progress * headerHeight)
                            .padding(.bottom, -progress * 10)
                            .padding(.horizontal, -progress * 15)
                    }
                }
                .padding(.bottom, 65)
                .frame(height: threeshold2Height, alignment: .bottomLeading)
                
                TDExpandableText(text: configuration.title, limit: 1)
                    .padding(.bottom, 120)
                    .frame(height: threeshold2Height, alignment: .bottomLeading)
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
    TDListView(
        configuration: .init(
            title: "To-do's",
            tabs: TDListTab.allCases,
            activeTab: .constant(.all),
            searchText: .constant(""),
            isSearchFocused: .constant(true)
        )
    ) {
        TDListContent(
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
            rows: .constant(
                Array(
                    repeating: TDListRow(id: UUID(), name: "Test list", image: Image.largecircleFillCircle, strikethrough: false),
                    count: 20
                )
            ),
            editMode: .constant(.inactive)
        )
    }
}
