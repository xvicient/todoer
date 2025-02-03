public protocol StringRepresentable {
    var rawValue: String { get }
}

public extension StringRepresentable {
    var rawValue: String {
        String(describing: self).components(separatedBy: "(").first ?? String(describing: self)
    }
}
