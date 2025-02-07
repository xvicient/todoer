public protocol StringRepresentable {
    var rawValue: String { get }
}

extension StringRepresentable {
    public var rawValue: String {
        String(describing: self).components(separatedBy: "(").first ?? String(describing: self)
    }
}
