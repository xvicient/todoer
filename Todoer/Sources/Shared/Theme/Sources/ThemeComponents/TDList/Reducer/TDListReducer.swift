import Common
import Foundation
import Strings
import SwiftUI
import xRedux

// MARK: - TDListViewState

/// View state shared by every list-style screen. Kept as a standalone (non-generic) type so a
/// single value flows through the shared reducer and its wrappers regardless of the element type.
public enum TDListViewState: Equatable, StringRepresentable {
    case idle
    case loading(Bool)
    case updating
    case adding
    case error(String)

    public static func error() -> TDListViewState {
        .error(Errors.default)
    }
}

public extension EditMode {
    var tdListViewState: TDListViewState {
        switch self {
        case .active: .updating
        default: .idle
        }
    }
}

// MARK: - TDListReducer

/// Reducer for the mechanics shared by every "toggleable, editable, searchable, sortable list"
/// screen: add / rename / toggle / delete / reorder rows, plus search focus, edit mode and tab
/// handling. Feature reducers (lists, items) embed `State` and forward `Action` via a
/// `case shared(TDListReducer<UseCase>.Action)`, keeping only their own screen-specific behaviour
/// (navigation, invitations, …) in the wrapper.
public struct TDListReducer<UseCase: TDListUseCaseApi>: Reducer {
    public typealias Element = UseCase.Element

    public enum Action: Equatable, Sendable, StringRepresentable {
        // MARK: - User actions
        case didTapSubmitButton(String?, String)
        case didTapToggleButton(String)
        case didTapDeleteButton(String)
        case didMove(IndexSet, Int)
        case didChangeSearchFocus(Bool)
        case didChangeEditMode(EditMode)
        case didChangeActiveTab(TDListTabItem)
        case didUpdateSearchText(String)
        case didTapDismissError

        // MARK: - Results
        case addResult(ActionResult<Element>)
        case updateResult(ActionResult<Element>)
        case voidResult(ActionResult<EquatableVoid>)
        case moveResult(ActionResult<EquatableVoid>)
    }

    public struct State {
        public var viewState: TDListViewState
        public var items: [Element]
        public var editMode: EditMode = .inactive
        public var searchText: String = ""
        public var isSearchFocused: Bool = false
        public var activeTab: TDListTabItem = .all

        public var tabs: [TDListTab] {
            TDListTab.allCases(
                active: activeTab,
                hidden: [items.count < 2 ? .sort : nil,
                         items.count < 1 ? .edit : nil].compactMap { $0 }
            )
        }

        public init(
            viewState: TDListViewState = .idle,
            items: [Element] = []
        ) {
            self.viewState = viewState
            self.items = items
        }

        /// Resets the transient "adding" UI state. Exposed so wrappers that finish an add-like
        /// flow of their own (e.g. importing shared lists) can reuse the exact same reset.
        public mutating func finishAdding() {
            viewState = .idle
            activeTab = .add(false)
            isSearchFocused = false
        }

        /// Rows currently visible for the active tab and search text.
        public func filteredRows() -> [Element] {
            items
                .filter(by: activeTab)
                .filter(by: searchText)
        }

        public var isLoading: Bool {
            switch viewState {
            case .loading(let isLoading): isLoading
            default: false
            }
        }

        public var contentStatus: TDContentStatus {
            switch viewState {
            case .adding: .adding
            case .updating where editMode.isEditing: .editing
            case .idle: .plain
            default: .plain
            }
        }

        /// Error message currently being surfaced, if any. Wrappers build their own
        /// `AppAlert` from this so the dismiss action lands in their own action space.
        public var errorMessage: String? {
            guard case .error(let message) = viewState else { return nil }
            return message
        }
    }

    let useCase: UseCase

    public init(useCase: UseCase) {
        self.useCase = useCase
    }
}

// MARK: - TDListShared

/// Marks a `State` that embeds a `TDListReducer` sub-state. Lets a single `Store` extension expose
/// the list bindings the view layer needs, so every list-style screen shares one binding surface.
/// `@MainActor` to match the `AppAlertState` isolation the conforming feature states already carry.
@MainActor
public protocol TDListSharedState {
    associatedtype UseCase: TDListUseCaseApi
    var shared: TDListReducer<UseCase>.State { get set }
}

/// Marks a wrapper `Reducer` whose `State` embeds a `TDListReducer` and whose `Action` can wrap the
/// shared reducer's actions. Feature reducers already provide both (a `shared` sub-state and a
/// `case shared(...)`); conforming just centralises the `Store` bindings below.
public protocol TDListSharedReducer: Reducer where State: TDListSharedState {
    static func shared(_ action: TDListReducer<State.UseCase>.Action) -> Action
}

// MARK: - Store bindings

/// The single source of the list view bindings, shared by every `TDListSharedReducer`
/// (Home, ListItems, …). Replaces the per-screen `Store` extensions that were byte-for-byte copies.
@MainActor
public extension Store where R: TDListSharedReducer {
    var activeTab: TDListTabItem {
        get { state.shared.activeTab }
        set { send(R.shared(.didChangeActiveTab(newValue))) }
    }

    var tabs: [TDListTab] {
        get { state.shared.tabs }
        set { }
    }

    var searchText: String {
        get { state.shared.searchText }
        set { send(R.shared(.didUpdateSearchText(newValue))) }
    }

    var rows: [TDListRow] {
        get { state.shared.filteredRows() }
        set { }
    }

    var editMode: EditMode {
        get { state.shared.editMode }
        set { send(R.shared(.didChangeEditMode(newValue))) }
    }

    var isSearchFocused: Bool {
        get { state.shared.isSearchFocused }
        set { send(R.shared(.didChangeSearchFocus(newValue))) }
    }

    var isLoading: Bool {
        state.shared.isLoading
    }

    var contentStatus: TDContentStatus {
        state.shared.contentStatus
    }
}
