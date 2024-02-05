import Foundation
import Combine

@testable import Todoer
import XCTest

@MainActor
final class TestStore<R: Reducer>: ObservableObject {
    @Published private var store: Store<R>
    private var expectedAction: R.Action?
    
    init(
        initialState: R.State,
        reducer: R
    ) {
        self.store = .init(initialState: initialState, reducer: reducer)
    }
    
    private func send(_ action: R.Action) {
        expectedAction = action
        store.send(action)
    }
    
    func send(
        _ action: R.Action,
        assert expectation: ((_ state: R.State) -> Bool)
    ) async {
        send(action)
        XCTAssertEqual(expectedAction, action)
        XCTAssert(expectation(store.state))
    }
    
    func receive(
        _ action: R.Action,
        assert expectation: ((_ state: R.State) -> Bool)
    ) async {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000)
        XCTAssertEqual(expectedAction, action)
        XCTAssert(expectation(store.state))
    }
}
