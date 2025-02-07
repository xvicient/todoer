import Application
import Combine
import Foundation

/// A test implementation of the Redux store that allows testing state changes and action processing
/// This class runs on the main actor to ensure thread safety
@MainActor
public final class TestStore<State, Action> where Action: Equatable {
    /// The underlying store instance
    private let store: Store<TestReducer<State, Action>>
    /// The test reducer used to track state changes and actions
    private let reducer: TestReducer<State, Action>

    /// Creates a new test store
    /// - Parameters:
    ///   - initialState: The initial state for the store
    ///   - reducer: The reducer that will process actions and update state
    public init<R: Reducer>(
        initialState: State,
        reducer: R
    )
    where
        R.State == State,
        R.Action == Action
    {
        self.reducer = TestReducer(
            reduce: reducer.reduce,
            initialState: initialState
        )
        self.store = Store(initialState: initialState, reducer: self.reducer)
    }

    /// Sends an action to the store and verifies the resulting state
    /// - Parameters:
    ///   - action: The action to send
    ///   - expectation: A closure that validates the resulting state
    /// The expectation closure should return true if the state is valid
    public func send(
        _ action: Action,
        assert expectation: ((_ state: State) -> Bool)
    ) async {
        store.send(action)
        assert(reducer.expectedAction == action)
        assert(expectation(reducer.expectedState))
    }

    /// Waits to receive a specific action and verifies the resulting state
    /// - Parameters:
    ///   - timeout: Maximum time in milliseconds to wait for the action (default: 5000)
    ///   - action: The action to expect
    ///   - expectation: A closure that validates the resulting state
    /// The expectation closure should return true if the state is valid
    /// Asserts if the action is not received within the timeout period
    public func receive(
        timeout: Int = 5000,
        _ action: Action,
        assert expectation: @escaping ((_ state: State) -> Bool)
    ) async {
        var expectedResultReceived = false
        var elapsedTime: UInt64 = 0
        let pace: UInt64 = 100

        reducer.expectedResult = (
            action,
            { [weak self] in
                guard let self else { return }
                assert(reducer.expectedAction == action)
                assert(expectation(reducer.expectedState))
                expectedResultReceived = true
            }
        )

        while !expectedResultReceived && elapsedTime < timeout {
            elapsedTime += pace
            try? await Task.sleep(nanoseconds: pace)
        }

        assert(expectedResultReceived, "Timeout waiting for expected action")
    }
}
