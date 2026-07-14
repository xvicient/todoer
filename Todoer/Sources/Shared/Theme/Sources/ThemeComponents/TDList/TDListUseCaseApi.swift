import Combine
import xRedux

/// Abstraction over the CRUD-ish operations a "toggleable, editable, sortable list" screen needs.
///
/// Both the lists screen (`HomeReducer`) and the items screen (`ListItemsReducer`) drive the same
/// UI mechanics through `TDListReducer`; each provides a concrete adapter that maps these generic
/// operations onto its own use case. The `Element` is the row model (a `UserList` or an `Item`).
public protocol TDListUseCaseApi {
    associatedtype Element: TDListRow & Equatable & Sendable

    /// Creates a new element from a user-provided name.
    func add(name: String) async -> ActionResult<Element>

    /// Persists an edited element (e.g. a rename).
    func update(_ element: Element) async -> ActionResult<Element>

    /// Toggles the completion state of `element`. The full `elements` collection is provided so
    /// adapters can derive dependent state (e.g. marking the parent list done when every item is).
    func toggle(_ element: Element, in elements: [Element]) async -> VoidResult

    /// Deletes `element`.
    func delete(_ element: Element) async -> VoidResult

    /// Persists the ordering of `elements`.
    func sort(_ elements: [Element]) async -> VoidResult
}
