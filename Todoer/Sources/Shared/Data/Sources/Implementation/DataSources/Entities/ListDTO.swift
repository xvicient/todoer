import FirebaseFirestore

struct ListDTO: Identifiable, Codable, Hashable {
    var id: String?
    let name: String
    let done: Bool
    var uid: [String]
    var index: Int
}

extension ListDTO: UpdateableDTO {
    public typealias IDType = String
    
    public func update(with newer: ListDTO) -> ListDTO {
        ListDTO(
            id: id,
            name: name != newer.name ? newer.name : name,
            done: done != newer.done ? newer.done : done,
            uid: uid,
            index: index
        )
    }
}
