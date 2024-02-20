import Foundation

extension Date {
	var milliseconds: Int {
		Int(timeIntervalSince1970 * 1000)
	}
}
