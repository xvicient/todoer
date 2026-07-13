import Testing
import ThemeComponents
import xRedux
import xReduxTest

@testable import Shared

@MainActor
struct TDListReducerTests {

    private typealias Reducer = TDListReducer<MockTDListUseCase>
    private typealias Store = TestStore<Reducer.State, Reducer.Action>

    private enum TestError: Error { case boom }

    private let useCase = MockTDListUseCase()
    private let rows = MockRowFactory.rows

    private func makeStore(
        viewState: TDListViewState = .idle,
        items: [MockRow] = MockRowFactory.rows
    ) -> Store {
        TestStore(
            initialState: .init(viewState: viewState, items: items),
            reducer: TDListReducer(useCase: useCase)
        )
    }

    // MARK: - Toggle

    @Test("Tapping toggle flips done and persists")
    func testToggle() async {
        useCase.toggleResult = .success()
        let store = makeStore()
        let id = rows[0].id

        await store.send(.didTapToggleButton(id)) {
            $0.viewState == .loading(false) && $0.items[0].done == true
        }

        await store.receive(.voidResult(.success())) {
            $0.viewState == .idle
        }
    }

    @Test("Toggle failure surfaces error")
    func testToggleFailure() async {
        useCase.toggleResult = .failure(TestError.boom)
        let store = makeStore()

        await store.send(.didTapToggleButton(rows[0].id)) {
            $0.viewState == .loading(false)
        }

        await store.receive(.voidResult(useCase.toggleResult)) {
            $0.errorMessage != nil
        }
    }

    // MARK: - Delete

    @Test("Tapping delete removes row and persists")
    func testDelete() async {
        useCase.deleteResult = .success()
        let store = makeStore()
        let target = rows[0]

        await store.send(.didTapDeleteButton(target.id)) {
            $0.viewState == .loading(false) && !$0.items.contains(target)
        }

        await store.receive(.voidResult(.success())) {
            $0.viewState == .idle
        }
    }

    // MARK: - Add

    @Test("Submitting a new name inserts the created row")
    func testAdd() async {
        let created = MockRow(id: "new", name: "New", done: false, index: 0)
        useCase.addResult = .success(created)
        let store = makeStore(viewState: .adding, items: [])

        await store.send(.didTapSubmitButton(nil, "New"))

        await store.receive(.addResult(.success(created))) {
            $0.items.first == created && $0.viewState == .idle
        }
    }

    // MARK: - Rename

    @Test("Submitting an edit renames the row")
    func testRename() async {
        var renamed = rows[0]
        renamed.name = "Renamed"
        useCase.updateResult = .success(renamed)
        let store = makeStore(viewState: .updating)

        await store.send(.didTapSubmitButton(rows[0].id, "Renamed"))

        await store.receive(.updateResult(.success(renamed))) {
            $0.items[0].name == "Renamed" && $0.viewState == .updating
        }
    }

    // MARK: - Move

    @Test("Moving a row persists the new order")
    func testMove() async {
        useCase.sortResult = .success()
        let store = makeStore(viewState: .updating)

        await store.send(.didMove(IndexSet(integer: 0), 2))

        await store.receive(.moveResult(.success())) {
            $0.viewState == .updating
        }
    }

    // MARK: - Search / edit mode / tabs

    @Test("Search focus is stored")
    func testSearchFocus() async {
        let store = makeStore()
        await store.send(.didChangeSearchFocus(true)) {
            $0.isSearchFocused == true
        }
    }

    @Test("Enabling edit mode moves to updating")
    func testEditMode() async {
        let store = makeStore()
        await store.send(.didChangeEditMode(.active)) {
            $0.editMode == .active && $0.viewState == .updating
        }
    }

    @Test("Selecting the add tab enters adding")
    func testAddTab() async {
        let store = makeStore()
        await store.send(.didChangeActiveTab(.add(true))) {
            $0.viewState == .adding
        }
    }

    @Test("Updating search text is stored")
    func testSearchText() async {
        let store = makeStore()
        await store.send(.didUpdateSearchText("abc")) {
            $0.searchText == "abc"
        }
    }

    // MARK: - Dismiss error

    @Test("Dismissing an error returns to idle")
    func testDismissError() async {
        let store = makeStore(viewState: .error("oops"))
        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }
}
