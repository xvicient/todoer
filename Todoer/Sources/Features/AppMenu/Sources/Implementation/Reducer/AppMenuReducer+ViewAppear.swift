import AppMenuContract
import Combine
import xRedux

/// Extension containing view appearance handling for the App Menu Reducer
extension AppMenu.Reducer {

    /// Handles the view's appearance by fetching the user's photo URL
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that initiates fetching the user's photo URL
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        return .task { send in
            await send(
                .getPhotoUrlResult(
                    useCase.getPhotoUrl()
                )
            )
        }
    }
}
