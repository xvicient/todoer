import Combine
import CoordinatorMocks
import Entities
import EntitiesMocks
import Testing
import Foundation
import ThemeComponents
import SwiftUI
import xRedux
import xReduxTest

@testable import ListItemsScreen

// MARK: - Cases

/// onAppear ✅
/// didTapSubmitItemButton(UUID, String) ✅
/// didTapCancelButton ✅
/// didTapToggleItemButton(UUID) ✅
/// didTapDeleteItemButton(UUID) ✅
/// didMoveItem(IndexSet, Int) ✅
/// didChangeSearchFocus(Bool) ✅
/// didChangeEditMode(EditMode) ✅
/// didChangeActiveTab(TDListTab) ✅
/// didUpdateSearchText(String) ✅
/// didTapDismissError ✅

// MARK: - ListItemsScreenTests

@MainActor
class ListItemsScreenTests {

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
    func testDidViewAppearAndFetchUsers_Success() async {
        givenASuccessItemsFetch()

        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }

        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) { [listMock, itemMock] in
            $0.viewState == .idle && $0.listName == listMock.name && $0.items == [itemMock]
        }
    }

    @Test("Fetch users fails after view appears")
    func testDidViewAppearAndFetchUsers_Failure() async {
        givenAFailureItemsFetch()

        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }

        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) { [listMock] in
            $0.viewState == .error(UseCaseError.error.localizedDescription) && $0.listName == listMock.name && $0.items.isEmpty
        }
    }

    @Test("Add new item and submit it successfully")
    func testDidTapAddRowButtonAndDidTapSubmitItemButton_Success() async {
        givenASuccessItemSubmit()

        var itemMockId: String!
        var itemsCount: Int!
        
        await store.send(.didChangeActiveTab(.add)) {
            itemMockId = $0.items.first?.id
            itemsCount = $0.items.count
            return $0.viewState == .adding &&
                   $0.isSearchFocused == false &&
                   $0.activeTab == .all
        }

        await store.send(.didTapSubmitItemButton(itemMockId, itemMock.name)) {
            $0.viewState == .adding
        }

        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .idle && $0.items.count == itemsCount + 1
        }
    }

    @Test("Add new item but submit fails")
    func testDidTapAddRowButtonAndDidTapSubmitItemButton_Failure() async {
        givenAFailureItemSubmit()
        
        var itemMockId: String!
        var itemsCount: Int!

        await store.send(.didChangeActiveTab(.add)) {
            itemMockId = $0.items.first?.id
            itemsCount = $0.items.count
            return $0.viewState == .adding &&
                   $0.isSearchFocused == false &&
                   $0.activeTab == .all
        }

        await store.send(.didTapSubmitItemButton(itemMockId, itemMock.name)) {
            $0.viewState == .adding
        }

        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription) &&
            $0.items.count == itemsCount
        }
    }

    @Test("Add new item and cancel it successfully")
    func testDidTapAddRowButtonAndDidTapCancelAddRowButton_Success() async {
        var itemsCount: Int!
        
        await store.send(.didChangeActiveTab(.add)) {
            itemsCount = $0.items.count
            return $0.viewState == .adding &&
                   $0.isSearchFocused == false &&
                   $0.activeTab == .all
        }

        await store.send(.didTapCancelButton) {
            $0.viewState == .idle && $0.items.count == itemsCount
        }
    }
    
    @Test(
        "Edit mode tapped and properly updated canceling any previous states",
        arguments: [
            (EditMode.active),
            (EditMode.inactive)
        ]
    )
    func testDidChangeEditMode_Success(editMode: (EditMode)) async {
        givenASuccessItemsFetch()

        await store.send(.didChangeActiveTab(.add)) {
            $0.viewState == .adding
        }
        
        await store.send(.didChangeEditMode(editMode)) {
            $0.viewState == editMode.viewState &&
            $0.editMode == editMode
        }
    }
    
    @Test("Edit mode and move item")
    func testDidChangeToEditModeAndMoveItem_Success() async {
        let mockItems = ItemMock.items(10)
        givenASuccessItemsFetch(mockItems)
        givenASuccessItemMove()
        
        let editMode: EditMode = .active
        
        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .idle
        }

        await store.send(.didChangeEditMode(editMode)) {
            $0.viewState == editMode.viewState &&
            $0.editMode == editMode
        }
        
        await store.send(.didMoveItem(IndexSet(integersIn: 6..<7), 2)) {
            $0.viewState == .updating && $0.items[2].id == mockItems[6].id
        }
    }
    
    @Test(
        "Filters tapped",
        arguments: [
            (TDListTabItem.all),
            (TDListTabItem.todo),
            (TDListTabItem.done)
        ]
    )
    func testDidTapFilter_Success(tab: (TDListTabItem)) async {
        givenASuccessItemsFetch()
        
        await store.send(.didChangeActiveTab(tab)) {
            $0.viewState == .idle && $0.activeTab == tab
        }
    }
    
    @Test("Did toggle item", arguments: [(true), (false)])
    func testDidTapToggleItemButton_Success(done: Bool) async {
        itemMock.done = done
        
        givenASuccessItemsFetch([itemMock])
        givenASuccessItemToogle()
        
        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .idle
        }

        await store.send(.didTapToggleItemButton(itemMock.id)) {
            $0.viewState == .loading(false) && $0.items[0].done == !itemMock.done
        }
        
        await store.receive(.voidResult(.success())) {
            $0.viewState == .idle
        }
    }
    
    @Test("Did delete item")
    func testDidTapDeleteItemButton_Success() async {
        givenASuccessItemsFetch([itemMock])
        givenASuccessItemDelete()
        
        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .idle
        }

        await store.send(.didTapDeleteItemButton(itemMock.id)) {
            $0.viewState == .loading(false) && !$0.items.contains { $0.id == itemMock.id }
        }
        
        await store.receive(.voidResult(.success())) {
            $0.viewState == .idle
        }
    }
    
    @Test("Did change search focus item", arguments: [(true)])
    func testDidChangeSearchFocus_Success(isFocused: Bool) async {
        await store.send(.didChangeActiveTab(.add)) {
            $0.viewState == .adding
        }
        
        await store.send(.didChangeSearchFocus(isFocused)) {
            $0.viewState == .idle
        }
    }
    
    @Test("Did update search text")
    func testDidUpdateSearchText_Success() async {
        await store.send(.didUpdateSearchText(itemMock.name)) {
            $0.viewState == .idle && $0.searchText == itemMock.name
        }
    }
    
    @Test("Did tap dismiss error")
    func testDidTapDismissError_Success() async {
        givenAFailureItemsFetch()

        await store.send(.onAppear) {
            $0.viewState == .loading(true)
        }

        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
        }
        
        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }

}

extension ListItemsScreenTests {
    fileprivate func givenASuccessItemsFetch(_ items: [Item] = [ItemMock.item]) {
        useCaseMock.fetchItemsResult = .success(
            items
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
    
    fileprivate func givenASuccessItemMove() {
        useCaseMock.voidResult = .success()
    }
    
    fileprivate func givenASuccessItemToogle() {
        useCaseMock.voidResult = .success()
    }
    
    fileprivate func givenASuccessItemDelete() {
        useCaseMock.voidResult = .success()
    }
}
