import FirebaseFirestore

public struct ItemDTO: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    let name: String
    var done: Bool
    var index: Int
}

extension ItemDTO: UpdateableDTO {
    public typealias IDType = String
    
    public func update(with newer: ItemDTO) -> ItemDTO {
        ItemDTO(
            id: self.id,
            name: self.name != newer.name ? newer.name : self.name,
            done: self.done != newer.done ? newer.done : self.done,
            index: self.index
        )
    }
}
