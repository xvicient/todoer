protocol Reducer<State, Action> {
    associatedtype State
    
    associatedtype Action
    
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action>
}
