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
}

public extension Array where Element == TDListTab {
    func removingSort(if condition: Bool) -> [TDListTab] {
        let result = self.sorted { $0.rawValue < $1.rawValue }
        return condition ? result.filter { $0 != .sort } : result
    }
}
