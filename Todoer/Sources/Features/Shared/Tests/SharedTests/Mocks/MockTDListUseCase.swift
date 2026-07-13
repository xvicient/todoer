import xRedux

@testable import Shared

final class MockTDListUseCase: TDListUseCaseApi, @unchecked Sendable {
    var addResult: ActionResult<MockRow>!
    var updateResult: ActionResult<MockRow>!
    var toggleResult: ActionResult<EquatableVoid> = .success()
    var deleteResult: ActionResult<EquatableVoid> = .success()
    var sortResult: ActionResult<EquatableVoid> = .success()

    private(set) var toggledElements: [MockRow]?

    func add(name: String) async -> ActionResult<MockRow> {
        addResult
    }

    func update(_ element: MockRow) async -> ActionResult<MockRow> {
        updateResult
    }

    func toggle(_ element: MockRow, in elements: [MockRow]) async -> ActionResult<EquatableVoid> {
        toggledElements = elements
        return toggleResult
    }

    func delete(_ element: MockRow) async -> ActionResult<EquatableVoid> {
        deleteResult
    }

    func sort(_ elements: [MockRow]) async -> ActionResult<EquatableVoid> {
        sortResult
    }
}
