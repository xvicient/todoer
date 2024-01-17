import Foundation

extension Error {
    var code: Int {
        (self as NSError).code
    }
}
