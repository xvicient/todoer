import Strings

public enum TDListTab: Int, CaseIterable {
    case add
    case sort
    case all
    case sharing
    case invitations
    
    var stringValue: String {
        switch self {
        case .add: Strings.TabAction.add
        case .sort: Strings.TabAction.sort
        case .all: Strings.TabAction.all
        case .sharing: Strings.TabAction.sharing
        case .invitations: Strings.TabAction.invitations
        }
    }
    
    public var isFilter: Bool {
        switch self {
        case .add, .sort: false
        case .all, .sharing, .invitations: true
        }
    }
    
    var activeTab: TDListTab {
        switch self {
        case .sharing: .sharing
        case .invitations: .invitations
        default: .all
        }
    }
}

public struct TDListTabItem: Hashable {
    let tab: TDListTab
    let isEnabled: Bool
    
    public init(
        tab: TDListTab,
        isEnabled: Bool
    ) {
        self.tab = tab
        self.isEnabled = isEnabled
    }
}
