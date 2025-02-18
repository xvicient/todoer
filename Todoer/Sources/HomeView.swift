import SwiftUI
import SwiftUIIntrospect

struct Home3: View {
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
            List {
                DummyMessagesView()
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .introspect(.list, on: .iOS(.v16, .v17, .v18)) { collection in
                scrollDelegate.scrollView = collection
                collection.delegate = scrollDelegate
                
                DispatchQueue.main.async {
                    scrollviewHeight = collection.contentSize.height
                    if originalOffset == .zero {
                        originalOffset = collection.contentOffset.y
                    }
                }
                
                scrollDelegate.onScroll = { offset in
                    contentOffset = (offset - originalOffset) * -1
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        minY = max(min(contentOffset, 0), -searchbarThreshold)
                    }
                }
                
                scrollDelegate.onScrollFinish = { [weak collection] offset in
                    guard let collection else { return }
                    contentOffset = (offset - originalOffset) * -1
                    guard contentOffset <= 0 else { return }
                    
                    let targetOffset: CGFloat
                    if contentOffset > -(searchbarThreshold / 2) {
                        targetOffset = originalOffset
                    } else {
                        targetOffset = originalOffset + searchbarThreshold
                    }
                    
                    collection.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: true)
                }
            }
            .safeAreaPadding(.top, 15)
            .safeAreaInset(edge: .top, spacing: 0) {
                searchBar()
            }
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: isSearching)
            .background(.black.opacity(0.8))
        }
        .onChange(of: isSearching) {
            if isSearching && minY <= -searchbarThreshold {
                return
            }
            let targetOffset = isSearching ? originalOffset + searchbarThreshold : originalOffset
            
            scrollDelegate.scrollView?.setContentOffset(
                CGPoint(x: 0, y: targetOffset),
                animated: true
            )
            
            scrollDelegate.onScroll?(targetOffset)
            scrollDelegate.onScrollFinish?(targetOffset)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    fileprivate func searchBar() -> some View {
        VStack {
            let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollviewHeight, 1), 0) * 0.5) : 1
            let progress = isSearching ? 1 : max(min(-minY / searchbarThreshold, 1), 0)
            
            VStack(spacing: 10) {
                Text("To-do's")
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
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
            .padding(.top, minY)
            .safeAreaPadding(.horizontal, 15)
        }
        .frame(height: 190)
    }
    
    /// Dummy Messages View
    @ViewBuilder
    func DummyMessagesView() -> some View {
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
    Home3()
}
