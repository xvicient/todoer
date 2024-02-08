import Foundation
import Combine
import XCTest

@testable import Todoer

final class TestStore<State, Action> where Action: Equatable {
    private let store: Store<TestReducer<State, Action>>
    private let reducer: TestReducer<State, Action>
    
    init<R: Reducer>(
        initialState: State,
        reducer: R
    )
    where
    R.State == State,
    R.Action == Action
    {
        self.reducer = TestReducer(reduce: reducer.reduce,
                                   initialState: initialState)
        self.store = Store(initialState: initialState, reducer: self.reducer)
    }
    
    func send(
        _ action: Action,
        assert expectation: ((_ state: State) -> Bool)
    ) async {
        store.send(action)
        XCTAssertEqual(reducer.expectedAction, action)
        XCTAssert(expectation(reducer.expectedState))
    }
    
    func receive(
        _ action: Action,
        assert expectation: ((_ state: State) -> Bool)
    ) async {
        sleep(1)
        XCTAssertEqual(reducer.expectedAction, action)
        XCTAssert(expectation(reducer.expectedState))
    }
}
