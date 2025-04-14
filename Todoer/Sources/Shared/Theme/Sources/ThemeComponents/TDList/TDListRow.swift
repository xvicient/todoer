import SwiftUI

public protocol TDListRow {
    var id: String { get }
    var done: Bool { get set }
    var name: String { get set }
    var index: Int { get set }
    var image: Image { get }
    var leadingActions: [TDListSwipeAction] { get }
    var trailingActions: [TDListSwipeAction] { get }
}

public extension TDListRow {
    var image: Image {
        done ? Image.largecircleFillCircle : Image.circle
    }
    
    var leadingActions: [TDListSwipeAction] {
        [done ? .undone : .done]
    }
}

public extension Array where Element: TDListRow {
    func index(for id: String) -> Int? {
        firstIndex(where: { $0.id == id })
    }
    
    func filter(by searchText: String) -> [Element] {
        searchText.isEmpty
            ? self
            : self.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
    }

    func filter(by tab: TDListTabItem) -> [Element] {
        switch tab {
        case .todo: filter { $0.done == false }
        case .done: filter { $0.done == true }
        default: self
        }
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
    
    /// Handles the reordering of elements with filtering by both completion status and search text.
    /// This method extends the basic move functionality to also account for search text filtering.
    ///
    /// - Parameters:
    ///   - fromIndex: The indices of elements being moved in the filtered view
    ///   - toIndex: The destination index in the filtered view
    ///   - isCompleted: Optional filter for completion status
    /// - Returns: The filtered lists after the move operation for backend updates
    @discardableResult
    mutating func move(
        fromIndex: IndexSet,
        toIndex: Int,
        activeTab: TDListTabItem
    ) -> [Element] {
        // Get the filtered lists that are currently visible
        let filteredLists = self
            .filter(by: activeTab)
        
        // Create a copy for moving and perform the move
        var movedFilteredLists = filteredLists
        movedFilteredLists.move(fromOffsets: fromIndex, toOffset: toIndex)
        
        // Create a mapping of original indices to filtered indices
        let filteredIndices = self.indices.filter { index in
            switch activeTab {
            case .todo, .done: self[index].done
            default: true
            }
        }
        
        // Update the main list while preserving items that don't match the filter
        for (newIndex, originalIndex) in filteredIndices.enumerated() {
            if newIndex < movedFilteredLists.count {
                self[originalIndex] = movedFilteredLists[newIndex]
            }
        }
        
        reIndex()
        
        // Return the moved filtered lists for backend updates
        return self
    }
}
