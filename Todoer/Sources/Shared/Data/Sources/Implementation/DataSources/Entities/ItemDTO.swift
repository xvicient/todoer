import FirebaseFirestore

public struct ItemDTO: Identifiable, Codable, Hashable {
    public var id: String?
    let name: String
    var done: Bool
    var index: Int
}

extension ItemDTO: UpdateableDTO {
    public typealias IDType = String
    
    public func update(with newer: ItemDTO) -> ItemDTO {
        ItemDTO(
            id: id,
            name: name != newer.name ? newer.name : name,
            done: done != newer.done ? newer.done : done,
            index: index
        )
    }
}
