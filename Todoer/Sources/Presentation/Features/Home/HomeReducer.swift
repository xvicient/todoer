import Combine
import SwiftUI

// MARK: - HomeReducer

protocol HomeDependencies {
    var useCase: HomeUseCaseApi { get }
    var coordinator: Coordinator { get}
}

extension Home {
    struct Reducer: Todoer.Reducer {
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
            case didSortLists(IndexSet, Int)

            
            // MARK: - Results
            case fetchDataResult(Result<([List], [Invitation]), Error>)
            case getPhotoUrlResult(Result<String, Error>)
            case toggleListResult(Result<Void, Error>)
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
        var lists = [ListRow]()
        var invitations = [Invitation]()
        var photoUrl = ""
    }
    
    struct ListRow: Identifiable {        
        let id = UUID()
        var list: List
        let leadingActions: [SwipeAction]
        let trailingActions: [SwipeAction]
        var isEditing: Bool
        
        init(list: List,
             leadingActions: [SwipeAction] = [],
             trailingActions: [SwipeAction] = [],
             isEditing: Bool = false) {
            self.list = list
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.isEditing = isEditing
        }
    }
    
    enum SwipeAction: Identifiable {
        case share
        case done
        case undone
        case delete
        
        var id: UUID { UUID() }
        
        var tint: Color {
            switch self {
            case .share: return .buttonBlack
            case .done: return .buttonBlack
            case .undone: return .buttonBlack
            case .delete: return .buttonDestructive
            }
        }
        
        var icon: Image {
            switch self {
            case .share: return .squareAndArrowUp
            case .done: return .largecircleFillCircle
            case .undone: return .circle
            case .delete: return .trash
            }
        }
    }
}
