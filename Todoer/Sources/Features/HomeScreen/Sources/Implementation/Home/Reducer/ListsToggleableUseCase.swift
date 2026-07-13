import Entities
import Shared
import xRedux

/// Adapts the list-level `HomeUseCaseApi` to the generic `TDListUseCaseApi` consumed by
/// `TDListReducer`. The `elements` passed to `toggle` are ignored here: a list's completion state
/// is independent of the other lists.
struct ListsToggleableUseCase: TDListUseCaseApi {
    typealias Element = UserList

    let useCase: HomeUseCaseApi

    func add(name: String) async -> ActionResult<UserList> {
        await useCase.addList(name: name)
    }

    func update(_ element: UserList) async -> ActionResult<UserList> {
        await useCase.updateList(list: element)
    }

    func toggle(_ element: UserList, in elements: [UserList]) async -> ActionResult<EquatableVoid> {
        await useCase.toggleList(list: element)
    }

    func delete(_ element: UserList) async -> ActionResult<EquatableVoid> {
        await useCase.deleteList(element.id)
    }

    func sort(_ elements: [UserList]) async -> ActionResult<EquatableVoid> {
        await useCase.sortLists(lists: elements)
    }
}
