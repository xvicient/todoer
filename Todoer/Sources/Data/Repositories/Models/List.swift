import Foundation

struct List: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let name: String
    var done: Bool
    var uuid: [String]
    let index: Int
}
