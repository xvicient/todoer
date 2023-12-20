import Foundation

typealias Reducer<State, Action, Dependencies> =
    (inout State, Action, Dependencies) -> Task<Action, Never>?

final class Store<State, Action, Dependencies>: ObservableObject {
    @Published private(set) var state: State

    private let dependencies: Dependencies
    private let reducer: Reducer<State, Action, Dependencies>

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Dependencies>,
        dependencies: Dependencies
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
    }

    func send(_ action: Action) async {
        guard let effect = reducer(&state, action, dependencies) else {
            return
        }
        
        await send(effect.value)
    }
}
