import Foundation
import Combine

@testable import Todoer
import XCTest

@MainActor
final class TestStore<R: Reducer>: ObservableObject {
    @Published private(set) var state: R.State
    private let reducer: R
    private var cancellables: Set<AnyCancellable> = []
    private var expectedAction: R.Action?
    
    init(
        initialState: R.State,
        reducer: R
    ) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func send(_ action: R.Action) {
        expectedAction = action
        switch reducer.reduce(&state, action) {
        case .none:
            break
        case .publish(let publisher):
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: send)
                .store(in: &cancellables)
        case .task(let task):
            guard let task = task else { return }
            Task {
                try? await send(task.value)
            }
        }
    }
    
    func receive(
        _ action: R.Action,
        assert expectation: ((_ state: inout R.State) -> Bool)
    ) async {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000)
//        XCTAssertEqual(expectedAction, action) // TODO: - conform equatable
        XCTAssert(expectation(&state))
    }
}
