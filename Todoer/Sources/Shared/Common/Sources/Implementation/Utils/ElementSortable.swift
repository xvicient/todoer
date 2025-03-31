import Foundation

public protocol ElementSortable {
    var id: UUID { get }
    var done: Bool { get set }
    var name: String { get set }
    var index: Int { get set }
}

public extension Array where Element: ElementSortable {
    func index(for id: UUID) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    mutating func replace(_ element: Element, at index: Int) {
        remove(at: index)
        insert(element, at: index)
    }
    
    mutating func sorted() {
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
    
    mutating func reIndex() {
        enumerated().forEach {
            self[$0.offset].index = $0.offset
        }
    }

    func filter(with searchText: String) -> [Element] {
        searchText.isEmpty
            ? self
            : self.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
    }

    func filter(by done: Bool?) -> [Element] {
        guard let done else { return self }
        return filter { $0.done == done }
    }
    
    /// Handles the reordering of elements when a user performs a drag and drop operation.
    /// This function manages both the UI state and the persistence of the new order.
    ///
    /// The function works with both all elements and sharing elements views by:
    /// 1. Mapping the source indices from the filtered view to the main element
    /// 2. Performing the move operation on the main element
    /// 3. Reindexing all elements to maintain proper order
    ///
    /// - Parameters:
    ///   - state: The current state to be modified
    ///   - fromIndex: The indices of elements being moved in the filtered view
    ///   - toIndex: The destination index in the filtered view
    ///   - isCompleted: The state of the current list filter
    /// - Returns: An effect that persists the new order through the use case
    mutating func move(
        fromIndex: IndexSet,
        toIndex: Int,
        isCompleted: Bool?
    ) {
        let sortedLists = filter(by: isCompleted)
        
        // 1. Map the indices from filtered list to main list
        let mainListFromIndex = IndexSet(fromIndex.map { sourceIndex in
            firstIndex { $0.id == sortedLists[sourceIndex].id } ?? 0
        })
        
        // 2. When moving to the end, toIndex will be equal to the array count
        let mainListToIndex: Int
        if toIndex >= sortedLists.count {
            mainListToIndex = count
        } else {
            mainListToIndex = firstIndex { $0.id == sortedLists[toIndex].id } ?? 0
        }
        
        // 3. Move elements in the main list
        move(fromOffsets: mainListFromIndex, toOffset: mainListToIndex)
        reIndex()
    }
}
