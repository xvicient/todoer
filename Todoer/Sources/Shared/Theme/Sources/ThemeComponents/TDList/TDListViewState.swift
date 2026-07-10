import Common
import Strings
import xRedux

public enum TDListViewState<Action: Equatable & Sendable>: Equatable, StringRepresentable {
    case idle
    case loading(Bool)
    case updating
    case adding
    case alert(AppAlert<Action>)

    public static func error(
        _ message: String = Errors.default,
        dismissAction: Action
    ) -> Self {
        .alert(
            .init(
                title: Strings.Errors.errorTitle,
                message: message,
                primaryAction: (dismissAction, Strings.Errors.okButtonTitle)
            )
        )
    }
}
