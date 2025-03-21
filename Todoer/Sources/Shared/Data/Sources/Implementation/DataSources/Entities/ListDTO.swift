import FirebaseFirestore

struct ListDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let done: Bool
    var uid: [String]
    var index: Int
}

extension ListDTO: UpdateableDTO {
    public typealias IDType = String
    
    public func update(with newer: ListDTO) -> ListDTO {
        ListDTO(
            id: self.id,
            name: self.name != newer.name ? newer.name : self.name,
            done: self.done != newer.done ? newer.done : self.done,
            uid: self.uid,
            index: self.index
        )
    }
}
