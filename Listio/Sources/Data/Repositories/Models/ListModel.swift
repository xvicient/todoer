import Foundation

struct ListModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let name: String
    var done: Bool
    var uuid: [String]
    let dateCreated: Int
}

extension ListDTO {
    var toDomain: ListModel {
        ListModel(documentId: id ?? "",
                  name: name,
                  done: done,
                  uuid: uuid,
                  dateCreated: dateCreated)
    }
}
