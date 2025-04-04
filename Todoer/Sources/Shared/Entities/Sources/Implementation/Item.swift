import Foundation
import Common

public struct Item: Identifiable, Equatable, Hashable, Sendable {
    private enum Errors: Error {
        case invalidId
    }
    public var id: String
    public var name: String
    public var done: Bool
    public var index: Int

    public init(
        id: String?,
        name: String,
        done: Bool,
        index: Int
    ) throws {
        guard let id else {
            throw Errors.invalidId
        }
        self.id = id
        self.name = name
        self.done = done
        self.index = index
    }
}
