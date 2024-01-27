import Foundation

// MARK: - HomeReducer

protocol HomeDependencies {
    var useCase: HomeUseCaseApi { get }
    var coordinator: Coordinator { get}
}

extension Home {
    struct Reducer: Todoer.Reducer {
        enum Action {
            // MARK: - View appear
            /// HomeReducer+ViewAppear
            case onViewAppear
            case onProfilePhotoAppear

            // MARK: - User actions
            /// HomeReducer+UserActions
            case didTapAcceptInvitation(String, String)
            case didTapDeclineInvitation(String)
            case didTapList(Int)
            case didTapToggleListButton(Int)
            case didTapDeleteListButton(Int)
            case didTapShareListButton(Int)
            case didTapEditListButton(Int)
            case didTapUpdateListButton(Int, String)
            case didTapCancelEditListButton
            case didTapAddRowButton
            case didTapCancelAddListButton
            case didTapSubmitListButton(String)
            case didTapSignoutButton
            case didTapAboutButton
            case didSortLists(IndexSet, Int)

            // MARK: - Results
            /// HomeReducer+Results
            case fetchDataResult(Result<([List], [Invitation]), Error>)
            case getPhotoUrlResult(Result<String, Error>)
            case toggleListResult(Result<List, Error>)
            case deleteListResult(Result<Void, Error>)
            case acceptInvitationResult(Result<Void, Error>)
            case declineInvitationResult(Result<Void, Error>)
            case addListResult(Result<List, Error>)
            case sortListsResult(Result<Void, Error>)
        }
        
        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }
        
        enum ViewState {
            case idle
            case loading
            case addingList
            case sortingList
            case updatingList
            case editingList
            case unexpectedError
        }
        
        internal let dependencies: HomeDependencies
        
        init(dependencies: HomeDependencies) {
            self.dependencies = dependencies
        }
        
        // MARK: - Reduce
        
        @MainActor
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            
            switch (state.viewState, action) {
            case (.idle, .onViewAppear):
                return onAppear(
                    state: &state
                )
            
            case (_, .onProfilePhotoAppear):
                return onProfilePhotoAppear(
                    state: &state
                )
                
            case (.idle, .didTapAcceptInvitation(let listId, let invitationId)):
                return onDidTapAcceptInvitation(
                    state: &state,
                    listId: listId,
                    invitationId: invitationId
                )
                
            case (.idle, .didTapDeclineInvitation(let invitationId)):
                return onDidTapDeclineInvitation(
                    state: &state,
                    invitationId: invitationId
                )
                
            case (.idle, .didTapList(let index)):
                return onDidTapList(
                    state: &state,
                    index: index
                )
            
            case (.idle, .didTapToggleListButton(let index)):
                return onDidTapToggleListButton(
                    state: &state,
                    index: index
                )
                
            case (.idle, .didTapDeleteListButton(let index)):
                return onDidTapDeleteListButton(
                    state: &state,
                    index: index
                )
                
            case (.idle, .didTapShareListButton(let index)):
                return onDidTapShareListButton(
                    state: &state,
                    index: index
                )
                
            case (.idle, .didTapEditListButton(let index)):
                return onDidTapEditListButton(
                    state: &state,
                    index: index
                )
                
            case (.editingList, .didTapCancelEditListButton):
                return onDidTapCancelEditListButton(
                    state: &state
                )
                
            case (.editingList, .didTapUpdateListButton(let index, let name)):
                return onDidTapUpdateListButton(
                    state: &state,
                    index: index,
                    name: name
                )
                
            case (.idle, .didTapAddRowButton):
                return onDidTapAddRowButton(
                    state: &state
                )
                
            case (.addingList, .didTapCancelAddListButton):
                return onDidTapCancelAddListButton(
                    state: &state
                )
                
            case (.addingList, .didTapSubmitListButton(let name)):
                return onDidTapSubmitListButton(
                    state: &state,
                    newListName: name
                )
                
            case (.idle, .didTapSignoutButton):
                return onDidTapSignoutButton(
                    state: &state
                )
                
            case (.idle, .didTapAboutButton):
                return onDidTapAboutButton(
                    state: &state
                )
                
            case (.idle, .didSortLists(let fromIndex, let toIndex)):
                return onDidSortLists(
                    state: &state,
                    fromIndex: fromIndex,
                    toIndex: toIndex
                )
                
            case (.idle, .fetchDataResult(let result)),
                (.loading, .fetchDataResult(let result)):
                return onFetchDataResult(
                    state: &state,
                    result: result
                )
                
            case (_, .getPhotoUrlResult(let result)):
                return onPhotoUrlResult(
                    state: &state,
                    result: result
                )
                
            case (.updatingList, .toggleListResult(let result)):
                return onToggleListResult(
                    state: &state,
                    result: result
                )
                
            case (.updatingList, .deleteListResult(let result)):
                return onDeleteListResult(
                    state: &state,
                    result: result
                )
                
            case (_, .acceptInvitationResult(let result)):
                return onAcceptInvitationResult(
                    state: &state,
                    result: result
                )
                
            case (_, .declineInvitationResult(let result)):
                return onDeclineInvitationResult(
                    state: &state,
                    result: result
                )
                
            case (.addingList, .addListResult(let result)),
                (.editingList, .addListResult(let result)):
                return onAddListResult(
                    state: &state,
                    result: result
                )
                
            case (.sortingList, .sortListsResult(let result)):
                return onSortListsResult(
                    state: &state,
                    result: result
                )
            
            default:
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}
