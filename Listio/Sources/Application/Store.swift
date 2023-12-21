import Foundation

typealias Reducer<State, Action, Dependencies, Coordinator> =
    (inout State, Action, Dependencies, Coordinator) -> Task<Action, Never>?

@MainActor
final class Store<State, Action, Dependencies>: ObservableObject {
    @Published private(set) var state: State
    private let dependencies: Dependencies
    private let reducer: Reducer<State, Action, Dependencies, Coordinator>
    private let coordinator: Coordinator

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Dependencies, Coordinator>,
        dependencies: Dependencies,
        coordinator: Coordinator
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
        self.coordinator = coordinator
    }

    func send(_ action: Action) async {
        guard let effect = reducer(&state, action, dependencies, coordinator) else {
            return
        }
        await send(effect.value)
    }
}
