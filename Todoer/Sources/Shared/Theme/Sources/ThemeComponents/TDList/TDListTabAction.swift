import Strings

public enum TDListTabAction: Int, CaseIterable {
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
}

public struct TDListTabActionItem: Hashable {
    let tab: TDListTabAction
    let isEnabled: Bool
    
    public init(
        tab: TDListTabAction,
        isEnabled: Bool
    ) {
        self.tab = tab
        self.isEnabled = isEnabled
    }
}
