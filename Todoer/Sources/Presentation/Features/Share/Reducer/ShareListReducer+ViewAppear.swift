// MARK: - View appear

@MainActor
internal extension ShareList.Reducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        .task { send in
            await send(
                .fetchUsersResult(
                    dependencies.useCase.fetchUsers(
                        uids: dependencies.list.uid
                    )
                )
            )
        }
    }
}
