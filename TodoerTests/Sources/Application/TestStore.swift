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
    
    @MainActor
    func send(
        _ action: Action,
        assert expectation: ((_ state: State) -> Bool)
    ) async {
        store.send(action)
        XCTAssertEqual(reducer.expectedAction, action)
        XCTAssert(expectation(reducer.expectedState))
    }
    
    @MainActor
    func receive(
        timeout: Int = 5000,
        _ action: Action,
        assert expectation: @escaping ((_ state: State) -> Bool)
    ) async {
        var expectedResultReceived = false
        var elapsedTime: UInt64 = 0
        var pace: UInt64 = 100
        
        reducer.expectedResult = (action, { [weak self] in
            guard let self else { return }
            XCTAssertEqual(reducer.expectedAction, action)
            XCTAssert(expectation(reducer.expectedState))
            expectedResultReceived = true
        })
        
        while !expectedResultReceived && elapsedTime < timeout {
            elapsedTime += pace
            try? await Task.sleep(nanoseconds: pace)
        }
        
        guard expectedResultReceived else {
            XCTFail("Timeout waiting for expected action")
            return
        }
    }
}
