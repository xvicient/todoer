@testable import Todoer

struct ListMock {
	static var list: List {
		lists(1).first!
	}

	static func lists(_ count: Int) -> [List] {
		(0..<count).map {
			List(
				documentId: String($0),
				name: String($0),
				done: false,
				uid: [String($0)],
				index: $0
			)
		}
	}
}
