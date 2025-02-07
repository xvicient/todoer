import Foundation

extension Error {
    public var code: Int {
        (self as NSError).code
    }
}
