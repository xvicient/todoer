/// Extension providing safe subscript access to Collection types
public extension Collection {
    /// Safely accesses an element at the specified index
    /// - Parameter index: The index to access
    /// - Returns: The element at the specified index if it exists, nil otherwise
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
