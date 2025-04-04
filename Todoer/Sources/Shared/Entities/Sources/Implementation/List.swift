import Foundation
import Common

public struct UserList: Identifiable, Equatable, Hashable, Sendable {
    private enum Errors: Error {
        case invalidId
    }
    public let id: String
    public var name: String
    public var done: Bool
    public var uid: [String]
    public var index: Int

    public init(
        id: String?,
        name: String,
        done: Bool,
        uid: [String],
        index: Int
    ) throws {
        guard let id else {
            throw Errors.invalidId
        }
        self.id = id
        self.name = name
        self.done = done
        self.uid = uid
        self.index = index
    }
}
