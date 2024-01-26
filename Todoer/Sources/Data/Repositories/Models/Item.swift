import Foundation

struct Item: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    var name: String
    var done: Bool
    let index: Int
}
