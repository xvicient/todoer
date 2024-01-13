import Combine
import SwiftUI

// MARK: - HomeReducer

protocol HomeDependencies {
    var useCase: HomeUseCaseApi { get }
    var coordinator: Coordinator { get}
}

extension Home {
    struct Reducer: Listio.Reducer {
        enum Action {
            // MARK: - View appear
            case onViewAppear
            case onProfilePhotoAppear
            
            // MARK: - User actions
            case didTapAcceptInvitation(String, String)
            case didTapDeclineInvitation(String)
            case didTapList(Int)
            case didTapToggleListButton(Int)
            case didTapDeleteListButton(Int)
            case didTapShareListButton(Int)
            case didTapAddRowButton
            case didTapCancelAddRowButton
            case didTapSubmitListButton(String)
            case didTapSignoutButton

            
            // MARK: - Results
            case fetchDataResult(Result<([List], [Invitation]), Error>)
            case getPhotoUrlResult(Result<String, Error>)
            case toggleListResult(Result<Void, Error>)
            case acceptInvitationResult(Result<Void, Error>)
            case declineInvitationResult(Result<Void, Error>)
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
            case unexpectedError
        }
        
        internal let dependencies: HomeDependencies
        
        init(dependencies: HomeDependencies) {
            self.dependencies = dependencies
        }
    }
}

// MARK: - Private

internal extension Home.Reducer {
    
    // MARK: - ViewModel
    
    @MainActor
    struct ViewModel {
        var listsSection = ListsSection()
        var invitations = [Invitation]()
        var photoUrl = ""
    }
    
    // MARK: - TDListSectionViewModel
    
    final class ListsSection: TDListSectionViewModel {
        var rows: [any TDSectionRow] = []
        var leadingActions: (any TDSectionRow) -> [TDSectionRowActionType] {
            { [$0.done ? .undone : .done] }
        }
        var trailingActions: [TDSectionRowActionType] = [.share, .delete]
    }
    
    // MARK: - EmptyRow
    
    struct EmptyRow: TDSectionRow {
        var id = UUID()
        var documentId = ""
        var name = ""
        var done = false
        var isEditing = true
    }
}
