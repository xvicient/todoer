import SwiftUI
import Strings

public enum TDListTab: Int, CaseIterable, Equatable, Sendable {
    case add
    case edit
    case sort
    case all
    case todo
    case done
    
    var stringValue: String {
        switch self {
        case .add: Strings.TabAction.add
        case .sort: Strings.TabAction.sort
        case .edit: ""
        case .all: Strings.TabAction.all
        case .todo: Strings.TabAction.todo
        case .done: Strings.TabAction.done
        }
    }
    
    public var isFilter: Bool {
        switch self {
        case .add, .sort, .edit: false
        case .all, .done, .todo: true
        }
    }
    
    public var isCompleted: Bool? {
        switch self {
        case .done:
            return true
        case .todo:
            return false
        default:
            return nil
        }
    }
    
    public static func tabs(for count: Int) -> [TDListTab] {
        guard count > 1 else {
            return TDListTab.allCases.compactMap { $0 == .sort ? nil : $0 }
        }
        return TDListTab.allCases
    }
}

public struct TDListTabButtonView: View {
    @Namespace private var tabAnimation
    @Binding var slideDirection: TDListView.SlideDirection
    @Binding var activeTab: TDListTab
    var tabs: [TDListTab]
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(tabs.filter({ !$0.isFilter }), id: \.self) { tab in
                    button(tab: tab) {
                        activeTab = tab
                    }
                }
                if !tabs.filter(\.isFilter).isEmpty {
                    Divider()
                        .frame(width: 1, height: 30)
                        .background(Color.gray)
                    ForEach(tabs.filter({ $0.isFilter }), id: \.self) { tab in
                        button(tab: tab) {
                            slideDirection = tab.rawValue > activeTab.rawValue ? .forward : .backward
                            withAnimation {
                                activeTab = tab
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 50)
    }

    @ViewBuilder
    fileprivate func button(
        tab: TDListTab,
        action: @escaping () -> Void) -> some View {
        switch tab {
        case .edit:
            EditButton()
                .tabButtonStyle(namespace: tabAnimation, item: tab, active: tab == activeTab)
        default:
            Button(action: action) {
                Text(tab.stringValue)
                    .tabButtonStyle(namespace: tabAnimation, item: tab, active: tab == activeTab)
            }
            .buttonStyle(.plain)
        }
    }
}

fileprivate struct TabButtonModifier: ViewModifier {
    var namespace: Namespace.ID
    var item: TDListTab
    var active: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundStyle(item.isFilter ? (active ? .white : .black) : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background {
                if item.isFilter {
                    if active {
                        Capsule()
                            .fill(Color.primary)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: namespace)
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
}

fileprivate extension View {
    func tabButtonStyle(namespace: Namespace.ID, item: TDListTab, active: Bool) -> some View {
        modifier(TabButtonModifier(namespace: namespace, item: item, active: active))
    }
}
