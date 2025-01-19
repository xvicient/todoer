import Foundation

public enum AlertStyle: Equatable, Identifiable, Sendable {
    public var id: UUID { UUID() }
    case error(String)
    case destructive
}
