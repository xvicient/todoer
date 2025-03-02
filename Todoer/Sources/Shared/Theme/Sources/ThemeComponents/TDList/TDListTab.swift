import Strings

public enum TDListTab: Int, CaseIterable {
    case add
    case sort
    case all
    case sharing
    
    var stringValue: String {
        switch self {
        case .add: Strings.TabAction.add
        case .sort: Strings.TabAction.sort
        case .all: Strings.TabAction.all
        case .sharing: Strings.TabAction.sharing
        }
    }
    
    public var isFilter: Bool {
        switch self {
        case .add, .sort: false
        case .all, .sharing: true
        }
    }
    
    var activeTab: TDListTab {
        switch self {
        case .sharing: .sharing
        default: .all
        }
    }
}

public extension Array where Element == TDListTab {
    func removingSort(if condition: Bool) -> [TDListTab] {
        let result = self.sorted { $0.rawValue < $1.rawValue }
        return condition ? result.filter { $0 != .sort } : result
    }
}
