import Foundation
import Combine

typealias Reducer<State, Action, Dependencies> =
    (inout State, Action, Dependencies) -> AnyPublisher<Action, Never>?

final class Store<State, Action, Dependencies>: ObservableObject {
    @Published private(set) var state: State

    private let dependencies: Dependencies
    private let reducer: Reducer<State, Action, Dependencies>
    private var effectCancellables: Set<AnyCancellable> = []

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Dependencies>,
        dependencies: Dependencies
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
    }

    func send(_ action: Action) {
        guard let effect = reducer(&state, action, dependencies) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}
