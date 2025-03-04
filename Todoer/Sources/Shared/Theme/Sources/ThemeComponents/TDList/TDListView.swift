import SwiftUI
import Combine
import ThemeAssets
import Strings

// MARK: - TDList

public struct TDListView: View {
    
    public typealias Actions = (TDListTab) -> Void
    
    enum SlideDirection {
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
        
        public init(
            title: String,
            tabs: [TDListTab]
        ) {
            self.title = title
            self.tabs = tabs
        }
    }
    
    /// init properties
    private let listContent: () -> AnyView
    private let actions: Actions
    private let configuration: Configuration
    @Binding private var searchText: String
    @FocusState.Binding private var isSearchFocused: Bool
    @Binding private var activeTab: TDListTab
    
    /// Animation properties
    @Namespace private var tabAnimation
    @State private var slideDirection: SlideDirection = .forward
    private let headerAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.8)
    
    /// Scrolling properties
    @State private var minY: CGFloat = 0.0
    @State private var isScrolling = false
    private let searchbarThreshold: CGFloat = 60.0
    private let headerHeight: CGFloat = 145.0
    
    /// Toolbar  properties
    @Environment(\.presentationMode) private var presentationMode
    private var hasBackButton: Bool {
        presentationMode.wrappedValue.isPresented
    }
    
    public init(
        @ViewBuilder content: @escaping () -> AnyView,
        actions: @escaping Actions,
        configuration: Configuration,
        searchText: Binding<String>,
        isSearchFocused: FocusState<Bool>.Binding,
        activeTab: Binding<TDListTab>
    ) {
        self.listContent = content
        self.actions = actions
        self.configuration = configuration
        self._searchText = searchText
        self._isSearchFocused = isSearchFocused
        self._activeTab = activeTab
    }
    
    public var body: some View {
        list
            .id(activeTab.rawValue)
            .transition(slideDirection.transition)
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
                guard !isSearchFocused else { return }
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
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                withAnimation(headerAnimation) {
                    proxy.scrollTo(0, anchor: .top)
                } completion: {
                    withAnimation(headerAnimation.delay(0.1)) {
                        minY = 0
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
                header()
            }
        }
    }
    
    @ViewBuilder
    fileprivate func header() -> some View {
        ZStack {
            let progress = max(min(-minY / searchbarThreshold, 1), 0)
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
                .padding(.top, (progress * 20))
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
                
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(configuration.tabs.filter({ !$0.isFilter }), id: \.self) { item in
                            tabButton(
                                item: item
                            )
                        }
                        if !configuration.tabs.filter({ $0.isFilter }).isEmpty {
                            Divider()
                                .frame(width: 1, height: 30)
                                .background(Color.gray)
                            ForEach(configuration.tabs.filter({ $0.isFilter }), id: \.self) { item in
                                tabButton(
                                    item: item
                                )
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(height: 50)
                .safeAreaPadding(.bottom, -minY)
            }
            .safeAreaPadding(.horizontal, 15)
            .frame(height: headerHeight, alignment: .bottom)
            VStack {
                Text(configuration.title)
                    .font(.largeTitle.bold())
                    .lineLimit(1)
                    .safeAreaPadding(.bottom, (110 - (21 * progress))-minY)
                    .frame(height: headerHeight, alignment: .bottomLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .safeAreaPadding(.leading, hasBackButton ? 15 + (15 * progress) : 15)
        }
    }
    
    @ViewBuilder
    fileprivate func tabButton(
        item: TDListTab
    ) -> some View {
        Button(action: {
            slideDirection = item.rawValue > activeTab.rawValue ? .forward : .backward
            withAnimation {
                activeTab = item.activeTab
                actions(item)
            }
        }) {
            Text(item.stringValue)
                .font(.callout)
                .foregroundStyle(item.isFilter ? (activeTab == item ? .white : .black) : .white)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    if item.isFilter {
                        if activeTab == item {
                            Capsule()
                                .fill(Color.primary)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: tabAnimation)
                        } else {
                            Capsule()
                                .fill(.background)
                        }
                    } else {
                        Capsule()
                            .fill(Color.primary)
                    }
                }
        }
        .buttonStyle(.plain)
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
        content: {
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
        actions: { _ in },
        configuration: .init(
            title: "To-do's",
            tabs: TDListTab.allCases
        ),
        searchText: .constant(""),
        isSearchFocused: FocusState<Bool>().projectedValue,
        activeTab: .constant(.all)
    )
}
