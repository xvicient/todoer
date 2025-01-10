import Foundation

public extension Error {
	var code: Int {
		(self as NSError).code
	}
}
