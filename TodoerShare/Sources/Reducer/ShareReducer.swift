import SwiftData
import Application
import Entities
import Foundation

extension Share {
    struct Reducer: Application.Reducer {
        enum Action: Equatable {
            // MARK: - View appear
            /// ShareReducer+ViewAppear
            case onViewAppear

            // MARK: - User actions
            /// ShareReducer+UserActions
            case didTapSave
            case didTapCancel

            // MARK: - Results
            /// ShareReducer+Results
            case fetchContentResult(ActionResult<String>)
            case addListResult(ActionResult<EquatableVoid>)
        }

        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }

        enum ViewState: Equatable {
            case idle
        }
        
        internal let dependencies: Dependencies
        internal var useCase: ShareUseCaseApi
        
        public init(
            dependencies: Dependencies,
            useCase: ShareUseCaseApi
        ) {
            self.dependencies = dependencies
            self.useCase = useCase
        }

        // MARK: - Reduce

        @MainActor
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {

            switch (state.viewState, action) {
            case (.idle, .onViewAppear):
                return onAppear(state: &state)
                
            case (.idle, .fetchContentResult(let result)):
                switch result {
                case .success(let content):
                    state.viewModel.content = content
                case .failure:
                    break
                }
                return .none

            case (.idle, .didTapSave):
                return onDidTapSave(
                    state: &state
                )
                
            case (.idle, .didTapCancel):
                dependencies.context?.completeRequest(returningItems: nil, completionHandler: nil)
                return .none

            case (.idle, .addListResult):
                dependencies.context?.completeRequest(returningItems: nil, completionHandler: nil)
                return .none
            }
        }
    }
}
