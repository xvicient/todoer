import Data

@testable import Todoer

struct ListMock {
	static var list: UserList {
		lists(1).first!
	}

	static func lists(_ count: Int) -> [UserList] {
		(0..<count).map {
			UserList(
				documentId: String($0),
				name: String($0),
				done: false,
				uid: [String($0)],
				index: $0
			)
		}
	}
}
