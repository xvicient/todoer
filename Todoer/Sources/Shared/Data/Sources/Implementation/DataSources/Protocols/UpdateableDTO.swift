import Foundation

/// Protocol for DTOs that can be merged with updated versions
public protocol UpdateableDTO {
    associatedtype IDType: Hashable
    
    /// The unique identifier for the DTO
    var id: IDType? { get }
    
    /// Merge the current DTO with an updated version
    /// - Parameter newer: The newer DTO to merge with
    /// - Returns: A merged DTO taking properties from both as appropriate
    func update(with newer: Self) -> Self
}
