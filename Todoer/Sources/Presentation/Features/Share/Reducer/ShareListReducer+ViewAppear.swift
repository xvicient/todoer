// MARK: - View appear

@MainActor
internal extension ShareList.Reducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        .task(Task {
            .fetchUsersResult(
                await dependencies.useCase.fetchUsers(
                    uids: dependencies.list.uid
                )
            )
        })
    }
}
