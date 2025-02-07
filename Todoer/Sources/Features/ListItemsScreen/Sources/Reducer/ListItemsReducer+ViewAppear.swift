import Combine
import Application

// MARK: - Reducer view appear

@MainActor
extension ListItems.Reducer {
    /// Handles the onAppear action for the ListItems screen
    /// - Parameters:
    ///   - state: Current state of the reducer
    /// - Returns: An effect that fetches the items for the current list
    /// 
    /// This function:
    /// 1. Sets the view state to loading
    /// 2. Initiates a fetch of all items for the current list
    /// 3. Maps the result to a fetchItemsResult action
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .publish(
            dependencies.useCase.fetchItems(
                listId: dependencies.list.documentId
            )
            .map { .fetchItemsResult(.success($0)) }
            .catch { Just(.fetchItemsResult(.failure($0))) }
            .eraseToAnyPublisher()
        )
    }
}
