import Combine

extension Publisher where Output: Collection, Output.Element: UpdateableDTO, Failure: Error {
    /// Merges incoming collections of DTOs with previously seen ones
    public func scanUpdates() -> AnyPublisher<[Output.Element], Failure> {
        self.scan([Output.Element]()) { stored, new in
            // Convert stored DTOs to dictionary (ignoring DTOs without ID)
            let storedDict = stored.reduce(into: [Output.Element.IDType: Output.Element]()) { dict, item in
                guard let id = item.id else { return }
                dict[id] = item
            }
            
            var updated = [Output.Element]()
            
            for newItem in new.filter({ $0.id != nil }) {
                if let newId = newItem.id,
                   let storedItem = storedDict[newId] {
                    // Merge changes using the protocol method
                    updated.append(storedItem.update(with: newItem))
                } else {
                    // Add new items (with valid ID)
                    updated.append(newItem)
                }
            }
            
            return updated
        }
        .eraseToAnyPublisher()
    }
}
