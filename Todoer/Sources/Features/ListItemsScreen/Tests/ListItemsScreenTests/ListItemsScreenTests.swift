import Combine
import CoordinatorMocks
import Entities
import EntitiesMocks
import Testing
import Foundation
import xRedux
import xReduxTest

@testable import ListItemsScreen

@MainActor
struct ListItemsScreenTests {

    private typealias ListItemsStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = ListItemsUseCaseMock.UseCaseError

    private struct ReducerDependencies: ListItemsReducerDependencies {
        let list: UserList
        let useCase: ListItemsUseCaseApi
    }

    private lazy var store: ListItemsStore<ListItemsReducer> = {
        TestStore(
            initialState: .init(listName: listMock.name),
            reducer: ListItemsReducer(
                dependencies: ReducerDependencies(
                    list: listMock,
                    useCase: useCaseMock
                )
            )
        )
    }()
    private var useCaseMock = ListItemsUseCaseMock()
    private var coordinatorMock = CoordinatorMock()
    private var itemMock = ItemMock.item
    private var listMock = ListMock.list

    @Test("Fetch users success after view appears")
    mutating func testDidViewAppearAndFetchUsers_Success() async {
        givenASuccessItemsFetch()

        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }

        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) { [listMock, itemMock] in
            $0.viewState == .idle && $0.listName == listMock.name && $0.items == [itemMock]
        }
    }

    @Test("Fetch users fails after view appears")
    mutating func testDidViewAppearAndFetchUsers_Failure() async {
        givenAFailureItemsFetch()

        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }

        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) { [listMock] in
            $0.viewState == .error(UseCaseError.error.localizedDescription) && $0.listName == listMock.name && $0.items.isEmpty
        }
    }

    @Test("Add new item and submit it successfully")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Success() async {
        givenASuccessItemSubmit()

        var itemMockId: UUID!
        
        await store.send(.didChangeActiveTab(.add)) {
            itemMockId = $0.items.first?.id
            return $0.viewState == .updating && $0.items.first?.isEditing == true
        }

        await store.send(.didTapSubmitItemButton(itemMockId, itemMock.name)) {
            $0.viewState == .updating
        }

        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .idle && !$0.items.contains(where: \.isEditing)
        }
    }

    @Test("Add new item but submit fails")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Failure() async {
        givenAFailureItemSubmit()
        
        var itemMockId: UUID!

        await store.send(.didChangeActiveTab(.add)) {
            itemMockId = $0.items.first?.id
            return $0.viewState == .updating && $0.items.first?.isEditing == true
        }

        await store.send(.didTapSubmitItemButton(itemMockId, itemMock.name)) {
            $0.viewState == .updating
        }

        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
            && $0.items.first?.isEditing == true
        }
    }

    @Test("Add new item and cancel it successfully")
    mutating func testDidTapAddRowButtonAndDidTapCancelAddRowButton_Success() async {
        await store.send(.didChangeActiveTab(.add)) {
            $0.viewState == .updating && $0.items.first?.isEditing == true
        }

        await store.send(.didTapCancelButton) {
            $0.viewState == .idle && !$0.items.contains(where: \.isEditing)
        }
    }

}

extension ListItemsScreenTests {
    fileprivate func givenASuccessItemsFetch() {
        useCaseMock.fetchItemsResult = .success(
            [itemMock]
        )
    }

    fileprivate func givenAFailureItemsFetch() {
        useCaseMock.fetchItemsResult = .failure(UseCaseError.error)
    }

    fileprivate func givenASuccessItemSubmit() {
        useCaseMock.addItemResult = .success(
            itemMock
        )
    }

    fileprivate func givenAFailureItemSubmit() {
        useCaseMock.addItemResult = .failure(UseCaseError.error)
    }
}
