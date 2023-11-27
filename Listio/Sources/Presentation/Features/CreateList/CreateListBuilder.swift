struct CreateListBuilder {
    @MainActor
    static func makeCreateList() -> CreateListView {
        CreateListView(
            viewModel: CreateListViewModel(
                listsRepository: ListsRepository()
            )
        )
    }
}
