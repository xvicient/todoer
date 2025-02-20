import Common
import Strings
import SwiftUI

public struct TDListSection: View {
    public typealias Content = () -> AnyView

    public struct Configuration: TDFilledRowConfiguration {
        let title: String
        let addButtonTitle: String
        let isSortEnabled: Bool
        let lineLimit: Int?
        let isMoveEnabled: Bool
        let isSwipeEnabled: Bool

        public init(
            title: String,
            addButtonTitle: String,
            isSortEnabled: Bool,
            lineLimit: Int? = nil,
            isMoveEnabled: Bool,
            isSwipeEnabled: Bool
        ) {
            self.title = title
            self.addButtonTitle = addButtonTitle
            self.isSortEnabled = isSortEnabled
            self.lineLimit = lineLimit
            self.isMoveEnabled = isMoveEnabled
            self.isSwipeEnabled = isSwipeEnabled
        }
    }

    public struct Actions: TDFilledRowActions, TDEmptyRowActions {
        let onAddRow: () -> Void
        let onSortRows: () -> Void
        let onSubmit: (String) -> Void
        let onUpdate: (UUID, String) -> Void
        let onCancelAdd: () -> Void
        let onCancelEdit: (UUID) -> Void
        let onTap: ((UUID) -> Void)?
        let onSwipe: (UUID, TDSwipeAction) -> Void
        let onMove: (IndexSet, Int) -> Void

        public init(
            onAddRow: @escaping () -> Void,
            onSortRows: @escaping () -> Void,
            onSubmit: @escaping (String) -> Void,
            onUpdate: @escaping (UUID, String) -> Void,
            onCancelAdd: @escaping () -> Void,
            onCancelEdit: @escaping (UUID) -> Void,
            onTap: ((UUID) -> Void)? = nil,
            onSwipe: @escaping (UUID, TDSwipeAction) -> Void,
            onMove: @escaping (IndexSet, Int) -> Void
        ) {
            self.onAddRow = onAddRow
            self.onSortRows = onSortRows
            self.onSubmit = onSubmit
            self.onUpdate = onUpdate
            self.onCancelAdd = onCancelAdd
            self.onCancelEdit = onCancelEdit
            self.onTap = onTap
            self.onSwipe = onSwipe
            self.onMove = onMove
        }
    }

    private let configuration: Configuration
    private let actions: Actions
    private let rows: [TDListRow]

    public init(
        configuration: Configuration,
        actions: Actions,
        rows: [TDListRow]
    ) {
        self.configuration = configuration
        self.actions = actions
        self.rows = rows
    }

    public var body: some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
            if row.isEditing {
                TDEmptyRowView(
                    row: row,
                    actions: actions
                ).id(index)
            }
            else {
                TDFilledRowView(
                    row: row,
                    actions: actions,
                    configuration: configuration
                ).id(index)
            }
        }
        .if(configuration.isMoveEnabled) {
            $0.onMove(perform: actions.onMove)
        }
    }
}
