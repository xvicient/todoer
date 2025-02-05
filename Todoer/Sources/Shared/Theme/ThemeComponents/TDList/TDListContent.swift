import SwiftUI
import Common
import Strings

public struct TDListContent: View {
    public struct Configuration: TDFilledRowConfiguration {
        let lineLimit: Int?
        let isMoveEnabled: Bool
        let isSwipeEnabled: Bool
        
        public init(
            lineLimit: Int? = nil,
            isMoveEnabled: Bool,
            isSwipeEnabled: Bool
        ) {
            self.lineLimit = lineLimit
            self.isMoveEnabled = isMoveEnabled
            self.isSwipeEnabled = isSwipeEnabled
        }
    }
    
    public struct Actions: TDFilledRowActions, TDEmptyRowActions {
        let onSubmit: (String) -> Void
        let onUpdate: (UUID, String) -> Void
        let onCancelAdd: () -> Void
        let onCancelEdit: (UUID) -> Void
        let onTap: ((UUID) -> Void)?
        let onSwipe: (UUID, TDSwipeAction) -> Void
        let onMove: (IndexSet, Int) -> Void
        
        public init(
            onSubmit: @escaping (String) -> Void,
            onUpdate: @escaping (UUID, String) -> Void,
            onCancelAdd: @escaping () -> Void,
            onCancelEdit: @escaping (UUID) -> Void,
            onTap: ((UUID) -> Void)? = nil,
            onSwipe: @escaping (UUID, TDSwipeAction) -> Void,
            onMove: @escaping (IndexSet, Int) -> Void
        ) {
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
        ForEach(rows) {
            if $0.isEditing {
                TDEmptyRowView(
                    row: $0,
                    actions: actions
                )
            } else {
                TDFilledRowView(
                    row: $0,
                    actions: actions,
                    configuration: configuration
                )
            }
        }
        .if(configuration.isMoveEnabled) {
            $0.onMove(perform: actions.onMove)
        }
    }
}
