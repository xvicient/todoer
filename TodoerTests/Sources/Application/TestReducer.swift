@testable import Todoer

class TestReducer<State, Action>: Reducer where Action: Equatable {
    
    private let reduce: (inout State, Action) -> Effect<Action>
    var expectedAction: Action?
    var expectedState: State
    
    init(
        reduce: @escaping (inout State, Action) -> Effect<Action>,
        initialState: State
    ) {
        self.reduce = reduce
        self.expectedState = initialState
    }
    
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        expectedState = state
        expectedAction = action
        let effect = reduce(&expectedState, action)
        state = expectedState
        return effect
    }
}
