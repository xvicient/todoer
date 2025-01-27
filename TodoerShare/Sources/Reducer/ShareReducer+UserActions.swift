import Application

// MARK: - Reducer user actions

extension Share.Reducer {
    
    func onDidTapSave(
        state: inout State
    ) -> Effect<Action> {
        let listName = state.viewModel.content
        return .task { send in
            await send(
                .addListResult(
                    useCase.addList(name: listName)
                )
            )
        }
    }
}
