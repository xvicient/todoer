import SwiftUI
import ThemeComponents

@testable import Shared

/// Minimal `TDListRow` used to exercise `TDListReducer` without depending on a feature's concrete
/// element (whose `TDListRow` conformance lives inside that feature module).
struct MockRow: TDListRow, Equatable, Sendable {
    let id: String
    var name: String
    var done: Bool
    var index: Int

    var trailingActions: [TDListSwipeAction] { [.delete] }

    init(id: String, name: String, done: Bool = false, index: Int = 0) {
        self.id = id
        self.name = name
        self.done = done
        self.index = index
    }
}

enum MockRowFactory {
    static let rows: [MockRow] = [
        MockRow(id: "1", name: "First", done: false, index: 0),
        MockRow(id: "2", name: "Second", done: false, index: 1),
        MockRow(id: "3", name: "Third", done: true, index: 2),
    ]
}
