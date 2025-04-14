import SwiftUI
import Strings

public struct TDListTab: Equatable, Sendable, Identifiable {
    public var id: Int { item.position }
    public let item: TDListTabItem
    public var isActive: Bool
    
    func slideTransition(for active: TDListTabItem) -> TDSlideTransition {
        guard item.section == .filters else { return .forward }
        return item.position > active.position ? .forward : .backward
    }
    
    public static func allCases(
        active: TDListTabItem,
        hidden: [TDListTabItem]
    ) -> [TDListTab] {
        let isAddOn = {
            switch active {
            case .add(let isAddOn): isAddOn
            default: false
            }
        }()
        
        let activeAction = {
            switch active {
            case .all, .todo, .done: return active
            default: return .all
            }
        }()
        
        return [
            TDListTab(item: .add(isAddOn), isActive: false),
            TDListTab(item: .edit, isActive: false),
            TDListTab(item: .sort, isActive: false),
            TDListTab(item: .all, isActive: .all == activeAction),
            TDListTab(item: .todo, isActive: .todo == activeAction),
            TDListTab(item: .done, isActive: .done == activeAction)
        ].filter { !hidden.contains($0.item) }
    }
}

public enum TDListTabItem: Equatable, Sendable {
    case add(Bool), edit, sort, all ,todo, done
    
    var string: String {
        switch self {
        case .add(let isOn):
            if isOn {
                Strings.TabAction.cancel
            } else {
                Strings.TabAction.add
            }
        case .sort: Strings.TabAction.sort
        case .edit: ""
        case .all: Strings.TabAction.all
        case .todo: Strings.TabAction.todo
        case .done: Strings.TabAction.done
        }
    }
    
    var section: TDListTabSection {
        switch self {
        case .all, .todo, .done: .filters
        default: .actions
        }
    }
    
    var position: Int {
        switch self {
        case .add: 1
        case .sort: 2
        case .edit: 3
        case .all: 4
        case .todo: 5
        case .done: 6
        }
    }
    
    var activeId: Int {
        switch self {
        case .todo: 2
        case .done: 3
        default: 1
        }
    }
    
    public enum TDListTabSection: Equatable, Sendable {
        case actions, filters
    }
}

public struct TDListTabButtonView: View {
    @Namespace private var tabAnimation
    @Binding var slideTransition: TDSlideTransition
    @Binding var activeTab: TDListTabItem
    @Binding var tabs: [TDListTab]
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach($tabs, id: \.id) { $tab in
                    if tab.item.section == .actions {
                        button(tab: tab) {
                            withAnimation {
                                activeTab = tab.item
                            }
                        }
                    }
                }
                
                Divider()
                    .frame(width: 1, height: 30)
                    .background(Color.gray)
                
                ForEach($tabs, id: \.id) { $tab in
                    if tab.item.section == .filters {
                        button(tab: tab) {
                            slideTransition = tab.slideTransition(for: activeTab)
                            withAnimation {
                                activeTab = tab.item
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
            switch tab.item {
        case .edit:
            EditButton()
                .tabButtonStyle(namespace: tabAnimation, tab: tab)
        default:
            Button(action: action) {
                Text(tab.item.string)
                    .tabButtonStyle(namespace: tabAnimation, tab: tab)
            }
            .buttonStyle(.plain)
        }
    }
}

fileprivate struct TabButtonModifier: ViewModifier {
    var namespace: Namespace.ID
    var tab: TDListTab
    
    func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundStyle(tab.item.section == .filters ? (tab.isActive ? .white : .black) : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background {
                if tab.item.section == .filters {
                    if tab.isActive {
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
    func tabButtonStyle(namespace: Namespace.ID, tab: TDListTab) -> some View {
        modifier(TabButtonModifier(namespace: namespace, tab: tab))
    }
}
