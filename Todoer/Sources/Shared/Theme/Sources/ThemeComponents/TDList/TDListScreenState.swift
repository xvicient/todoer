import SwiftUI

/// Common state slice shared by list-driven screens (Home's list of lists,
/// ListItems' list of items). Composed as a field rather than adopted as a
/// protocol: `HomeReducer.State`/`ListItemsReducer.State` also conform to
/// xRedux's `AppAlertState` (`@MainActor`), and a second, plain protocol
/// conformance on the same struct made the compiler infer whole-struct
/// MainActor isolation for every stored property, not just the alert one.
public struct TDListScreenState<Action: Equatable & Sendable> {
    public var viewState: TDListViewState<Action>
    public var editMode: EditMode
    public var searchText: String
    public var isSearchFocused: Bool
    public var activeTab: TDListTabItem

    public init(
        viewState: TDListViewState<Action> = .idle,
        editMode: EditMode = .inactive,
        searchText: String = "",
        isSearchFocused: Bool = false,
        activeTab: TDListTabItem = .all
    ) {
        self.viewState = viewState
        self.editMode = editMode
        self.searchText = searchText
        self.isSearchFocused = isSearchFocused
        self.activeTab = activeTab
    }
}
