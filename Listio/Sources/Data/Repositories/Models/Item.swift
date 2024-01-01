import Foundation

struct Item: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let name: String
    var done: Bool
    let dateCreated: Int
}

extension ItemDTO {
    var toDomain: Item {
        Item(documentId: id ?? "",
                name: name,
                done: done,
                dateCreated: dateCreated)
    }
}
