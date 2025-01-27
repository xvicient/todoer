import Application

extension Share.Reducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        .task { send in
            await send(
                .fetchContentResult(
                    useCase.share(items: dependencies.items)
                )
            )
        }
    }
}
