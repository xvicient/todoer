import Foundation

extension Date {
    public var milliseconds: Int {
        Int(timeIntervalSince1970 * 1000)
    }
}
