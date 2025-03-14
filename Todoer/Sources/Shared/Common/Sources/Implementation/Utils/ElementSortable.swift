public protocol ElementSortable {
    var done: Bool { get }
    var name: String { get }
    var index: Int { get set }
}

extension Array where Element: ElementSortable {
    public mutating func sorted() {
        sort {
            if $0.done != $1.done {
                return !$0.done && $1.done
            }
            else {
                return $0.name.localizedCompare($1.name) == .orderedAscending
            }
        }

        reIndex()
    }
    
    public mutating func reIndex() {
        enumerated().forEach {
            self[$0.offset].index = $0.offset
        }
    }

    public func filter(with searchText: String) -> [Element] {
        searchText.isEmpty
            ? self
            : self.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
    }

}
