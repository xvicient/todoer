import Foundation

@MainActor
final class Store<R: Reducer>: ObservableObject {
    @Published private(set) var state: R.State
    private let reducer: R

    init(
        initialState: R.State,
        reducer: R
    ) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: R.Action) async {
        guard let effect = reducer.reduce(&state, action) else {
            return
        }
        await send(effect.value)
    }
}
