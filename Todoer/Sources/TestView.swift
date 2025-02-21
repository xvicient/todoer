import SwiftUI

struct TestView: View {
    enum Tab: String, CaseIterable {
        case all = "All"
        case personal = "Personal"
        case office = "Updates"
        case community = "Gaming"
    }
    
    class ScrollViewDelegate: NSObject, UICollectionViewDelegate {
        weak var scrollView: UIScrollView?
        var onScroll: ((CGFloat) -> Void)?
        var onScrollFinish: ((CGFloat) -> Void)?
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            onScroll?(scrollView.contentOffset.y)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                onScrollFinish?(scrollView.contentOffset.y)
            }
        }
    }
    
    private let scrollDelegate = ScrollViewDelegate()
    @State private var searchText: String = ""
    @FocusState private var isSearching: Bool
    @State private var activeTab: Tab = .all
    @Namespace private var animation
    @State private var contentOffset: CGFloat = 0.0
    @State  private var originalOffset: CGFloat = .zero
    @State private var scrollviewHeight: CGFloat = 0.0
    @State private var minY: CGFloat = 0.0
    private let searchbarThreshold: CGFloat = 60.0
    
    var body: some View {
        VStack {
            if #available(iOS 18.0, *) {
                ScrollViewReader { proxy in
                    List {
                        ForEach(0..<200, id: \.self) { n in
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
                    }
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                    .onScrollPhaseChange { _, _, context in
                        DispatchQueue.main.async {
                            let offset = context.geometry.contentOffset.y + context.geometry.contentInsets.top
                            
                            if offset < searchbarThreshold {
                                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                    proxy.scrollTo(0, anchor: .top)
                                }
                            }
                        }
                    }
                    .onScrollGeometryChange(for: CGFloat.self) {
                        $0.contentOffset.y + $0.contentInsets.top
                    } action: { _, offset in
                        DispatchQueue.main.async {
                            // minY = max(min(-offset, 0), -searchbarThreshold)
                            if abs(offset) == .zero {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                    minY = 0
                                }
                            } else {
                                if -offset > -searchbarThreshold {
                                    minY = -offset
                                } else {
                                    minY = -searchbarThreshold
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .safeAreaPadding(.top, 15)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        searchBar()
                    }
                    .background(.black.opacity(0.8))
                }
            }
            Text("\(minY)")
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    fileprivate func searchBar() -> some View {
        VStack {
            let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollviewHeight, 1), 0) * 0.5) : 1
            let progress =  max(min(-minY / searchbarThreshold, 1), 0)
            ZStack {
                VStack {
                    Text("To-do's")
                        .font(.largeTitle.bold())
//                        .scaleEffect(scaleProgress, anchor: .topLeading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20 - (20 * progress))
                    Spacer()
                }
                .zIndex(999)
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                        
                        TextField("Search", text: $searchText)
                            .focused($isSearching)
                        
                        if isSearching {
                            Button(action: {
                                isSearching = false
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                            })
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                        }
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15 - (progress * 15))
                    .frame(height: 45)
                    .clipShape(.capsule)
                    .background {
                        RoundedRectangle(cornerRadius: 25 - (progress * 25))
                            .fill(.background)
                            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                            .padding(.top, -progress * 190)
                            .padding(.bottom, -progress * searchbarThreshold)
                            .padding(.horizontal, -progress * 15)
                    }
                    
                    /// Custom Segmented Picker
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(Tab.allCases, id: \.rawValue) { tab in
                                Button(action: {
                                    withAnimation(.snappy) {
                                        activeTab = tab
                                    }
                                }) {
                                    Text(tab.rawValue)
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
                    .frame(height: 50)
                }
                .padding(.top, 60 + minY)
                .zIndex(0)
            }
            .safeAreaPadding(.horizontal, 15)
        }
        .frame(height: 190)
    }
    
    /// Dummy Messages View
    @ViewBuilder
    func DummyMessagesView() -> some View {
        ForEach(0..<200, id: \.self) { n in
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
            .listRowInsets(
                .init(
                    top: 8,
                    leading: 8,
                    bottom: 8,
                    trailing: 8
                )
            )
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                })
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                })
                Button(action: {
                    
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                })
            }
            .foregroundStyle(.gray.opacity(0.4))
            .padding(.horizontal, 5)
        }
    }
}

#Preview {
    TestView()
}

