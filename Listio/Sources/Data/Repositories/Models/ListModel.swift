import Foundation

struct ListModel: Identifiable {
    let id = UUID()
    let documentId: String?
    let name: String
    let done: Bool
    var uuid: [String]
    let dateCreated: Int
}

extension ListDTO {
    var toDomain: ListModel {
        ListModel(documentId: id,
                  name: name,
                  done: done,
                  uuid: uuid,
                  dateCreated: dateCreated)
    }
}
