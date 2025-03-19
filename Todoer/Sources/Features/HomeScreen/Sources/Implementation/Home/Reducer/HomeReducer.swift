import Common
import CoordinatorContract
import Entities
import Foundation
import HomeScreenContract
import Strings
import xRedux
import ThemeComponents
import SwiftUI

// MARK: - HomeReducer

typealias HomeData = Home.HomeData

extension Home {
    struct Reducer: xRedux.Reducer {

        enum Errors: Error, LocalizedError {
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }

            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

        enum Action: Equatable, StringRepresentable {
            // MARK: - View appear
            /// HomeReducer+ViewAppear
            case onViewAppear
            case onSceneActive

            // MARK: - User actions
            /// HomeReducer+UserActions
            case didTapList(UUID)
            case didTapSubmitListButton(String)
            case didTapCancelButton
            case didTapToggleListButton(UUID)
            case didTapShareListButton(UUID)
            case didTapDeleteListButton(UUID)
            case didMoveList(IndexSet, Int)
            case didChangeSearchFocus(Bool)
            case didChangeEditMode(EditMode)
            case didChangeActiveTab(TDListTab)
            case didUpdateSearchText(String)
            case didTapDismissError

            // MARK: - Results
            /// HomeReducer+Results
            case fetchDataResult(ActionResult<HomeData>)
            case addListResult(ActionResult<UserList>)
            case homeResult(ActionResult<EquatableVoid>)
            case addSharedListsResult(ActionResult<[UserList]>)
        }

        @MainActor
        struct State: AppAlertState {
            var viewState = ViewState.idle
            
            var lists = [WrappedUserList]()
            var invitations = [Invitation]()
            
            var editMode: EditMode = .inactive
            var activeTab: TDListTab = .all
            var searchText = ""
            var isSearchFocused: Bool = false
            
            var tabs: [TDListTab] {
                TDListTab.allCases
                    .removingSort(if: lists.filter { !$0.isEditing }.count < 2)
            }
            
            var isEditing: Bool {
                lists.contains(where: \.isEditing)
            }
            
            var isLoading: Bool {
                switch viewState {
                case .loading(let isLoading):
                    return isLoading
                default:
                    return false
                }
            }

            var alert: AppAlert<Action>? {
                guard case .alert(let data) = viewState else {
                    return nil

                }
                return data
            }
        }

        enum ViewState: Equatable, StringRepresentable {
            case idle
            case loading(Bool)
            case editing
            case alert(AppAlert<Action>)

            static func error(
                _ message: String = Errors.default
            ) -> ViewState {
                .alert(
                    .init(
                        title: Strings.Errors.errorTitle,
                        message: message,
                        primaryAction: (.didTapDismissError, Strings.Errors.okButtonTitle)
                    )
                )
            }
        }

        let dependencies: HomeScreenDependencies
        let useCase: HomeUseCaseApi = UseCase()

        init(dependencies: HomeScreenDependencies) {
            self.dependencies = dependencies
        }
    }
}

// MARK: - Bindings

@MainActor
extension Store<Home.Reducer> {
    var activeTab: TDListTab {
        get { state.activeTab }
        set { send(.didChangeActiveTab(newValue)) }
    }
    
    var searchText: String {
        get { state.searchText }
        set { send(.didUpdateSearchText(newValue)) }
    }
    
    var rows: [TDListRow] {
        get {
            state.lists
                .filter(by: activeTab.isCompleted)
                .filter(with: searchText)
                .map { $0.tdListRow }
        }
        set { }
    }
    
    var editMode: EditMode {
        get { state.editMode }
        set { send(.didChangeEditMode(newValue)) }
    }
    
    var isSearchFocused: Bool {
        get { state.isSearchFocused }
        set { send(.didChangeSearchFocus(newValue)) }
    }
}

extension Home.Reducer {
    struct WrappedUserList: Identifiable, Sendable, ElementSortable {
        let id: UUID
        var list: UserList
        let leadingActions: [TDSwipeAction]
        let trailingActions: [TDSwipeAction]
        var isEditing: Bool

        var done: Bool { list.done }
        var name: String { list.name }
        var index: Int {
            get { list.index }
            set { list.index = newValue }
        }

        init(
            id: UUID,
            list: UserList,
            leadingActions: [TDSwipeAction] = [],
            trailingActions: [TDSwipeAction] = [],
            isEditing: Bool = false
        ) {
            self.id = id
            self.list = list
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.isEditing = isEditing
        }
    }
}

extension Array where Element == Home.Reducer.WrappedUserList {
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
    
    mutating func replace(list: UserList, at index: Int) {
        remove(at: index)
        insert(list.toListRow, at: index)
    }
}

// MARK: - UserList to ListRow

extension UserList {
    var toListRow: Home.Reducer.WrappedUserList {
        Home.Reducer.WrappedUserList(
            id: id,
            list: self,
            leadingActions: [done ? .undone : .done],
            trailingActions: [.delete, .share]
        )
    }
}
