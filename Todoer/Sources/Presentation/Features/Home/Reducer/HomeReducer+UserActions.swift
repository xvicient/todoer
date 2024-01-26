import Foundation

// MARK: - Reducer user actions

@MainActor
internal extension Home.Reducer {
    func onDidTapAcceptInvitation(
        state: inout State,
        listId: String,
        invitationId: String
    ) -> Effect<Action> {
        return .task(Task {
            .acceptInvitationResult(
                await dependencies.useCase.acceptInvitation(
                        listId: listId,
                        invitationId: invitationId)
            )
        })
    }
    
    func onDidTapDeclineInvitation(
        state: inout State,
        invitationId: String
    ) -> Effect<Action> {
        return .task(Task {
            .declineInvitationResult(
                await dependencies.useCase.declineInvitation(
                        invitationId: invitationId)
            )
        })
    }
    
    func onDidTapList(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .unexpectedError
            return .none
        }
        dependencies.coordinator.push(.listItems(list))
        return .none
    }
    
    func onDidTapToggleListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard state.viewModel.lists[safe: index] != nil else {
            state.viewState = .unexpectedError
            return .none
        }
        state.viewState = .updatingList
        state.viewModel.lists[index].list.done.toggle()
        let list = state.viewModel.lists[index].list
        return .task(Task {
            .toggleListResult(
                await dependencies.useCase.updateList(
                    list: list
                )
            )
        })
    }
    
    func onDidTapDeleteListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .unexpectedError
            return .none
        }
        state.viewState = .updatingList
        state.viewModel.lists.remove(at: index)
        return .task(Task {
            .deleteListResult(
                await dependencies.useCase.deleteList(list.documentId)
            )
        })
    }
    
    func onDidTapShareListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .unexpectedError
            return .none
        }
        dependencies.coordinator.present(sheet: .shareList(list))

        return .none
    }
    
    func onDidTapEditListButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .unexpectedError
            return .none
        }
        state.viewState = .editingList
        state.viewModel.lists.remove(at: index)
        state.viewModel.lists.insert(newListRow(list: list), at: index)

        return .none
    }
    
    func onDidTapUpdateListButton(
        state: inout State,
        index: Int,
        name: String
    ) -> Effect<Action> {
        guard var list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .unexpectedError
            return .none
        }
        list.name = name
        return .task(Task {
            .addListResult(
                await dependencies.useCase.updateList(
                    list: list
                )
            )
        })
    }
    
    func onDidTapCancelEditListButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.lists.removeAll { $0.isEditing }
        return onAppear(state: &state)
    }
    
    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.viewModel.lists.contains(
            where: { $0.isEditing }
        ) else {
            return .none
        }
        state.viewState = .addingList
        state.viewModel.lists.append(newListRow())
        return .none
    }
    
    func onDidTapCancelAddListButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.lists.removeAll { $0.isEditing }
        return .none
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String
    ) -> Effect<Action> {
        return .task(Task {
            .addListResult(
                await dependencies.useCase.addList(
                    name: newListName
                )
            )
        })
    }
    
    func onDidTapSignoutButton(
        state: inout State
    ) -> Effect<Action> {
        switch dependencies.useCase.signOut() {
        case .success:
            dependencies.coordinator.loggOut()
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onDidSortLists(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        state.viewState = .sortingList
        state.viewModel.lists.move(fromOffsets: fromIndex, toOffset: toIndex)
        let lists = state.viewModel.lists
            .map { $0.list }
        return .task(Task {
            .sortListsResult(
                await dependencies.useCase.sortLists(
                    lists: lists
                )
            )
        })
    }
}

// MARK: - Private

private extension Home.Reducer {
    func newListRow(list: List = List.emptyList) -> ListRow {
        ListRow(
            list: list,
            isEditing: true
        )
    }
}

// MARK: - Empty list

private extension List {
    static var emptyList: List {
        List(
            documentId: "",
            name: "",
            done: false,
            uuid: [],
            index: Date().milliseconds
        )
    }
}
