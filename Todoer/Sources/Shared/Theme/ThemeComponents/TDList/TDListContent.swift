import SwiftUI
import Common
import Strings

public struct TDListContent: View {
    public struct Configuration {
        let rows: [TDListRow]
        let isMoveAllowed: Bool
        
        public init(
            rows: [TDListRow],
            isMoveAllowed: Bool
        ) {
            self.rows = rows
            self.isMoveAllowed = isMoveAllowed
        }
    }
    
    public struct Actions {
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
    
    @FocusState private var isEmptyRowFocused: Bool
    @State private var emptyRowText = ""
    
    public init(
        configuration: Configuration,
        actions: Actions
    ) {
        self.configuration = configuration
        self.actions = actions
    }
    
    public var body: some View {
        ForEach(
            Array(configuration.rows.enumerated()),
            id: \.element.id
        ) { index, row in
            if row.isEditing {
                emptyRow(row)
                    .id(row.id)
            } else {
                filledRow(row)
                    .id(row.id)
            }
        }
        .if(configuration.isMoveAllowed) {
            $0.onMove(perform: actions.onMove)
        }
    }
}

// MARK: - Empty row

private extension TDListContent {
    @ViewBuilder
    func emptyRow(
        _ row: TDListRow
    ) -> some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            TextField(Strings.List.newItemPlaceholder, text: $emptyRowText)
                .foregroundColor(Color.textBlack)
                .focused($isEmptyRowFocused)
                .onAppear {
                    emptyRowText = row.name
                }
                .onSubmit {
                    hideKeyboard()
                    if row.name.isEmpty {
                        actions.onSubmit($emptyRowText.wrappedValue)
                    }
                    else {
                        actions.onUpdate(row.id, $emptyRowText.wrappedValue)
                    }
                }
                .submitLabel(.done)
            Button(action: {
                hideKeyboard()
                if row.name.isEmpty {
                    actions.onCancelAdd()
                }
                else {
                    actions.onCancelEdit(row.id)
                }
            }) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.buttonBlack)
            }
            .buttonStyle(.borderless)
        }
        .frame(height: 40)
        .listRowInsets(
            .init(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        )
        .onAppear {
            isEmptyRowFocused = true
        }
    }
}

// MARK: - Filled row

private extension TDListContent {
    @ViewBuilder
    func filledRow(
        _ row: TDListRow
    ) -> some View {
        Group {
            HStack {
                row.image
                    .foregroundColor(Color.buttonBlack)
                Button(action: {
                    actions.onTap?(row.id)
                }) {
                    TDURLText(text: row.name)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .strikethrough(row.strikethrough)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .foregroundColor(Color.textBlack)
            }
            .frame(minHeight: 40)
        }
        .swipeActions(edge: .leading) {
            swipeActions(
                row.id,
                row.leadingActions
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(
                row.id,
                row.trailingActions
            )
        }
        .listRowInsets(
            .init(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        )
    }

    @ViewBuilder
    func swipeActions(
        _ rowID: UUID,
        _ swipeActions: [TDSwipeAction]
    ) -> some View {
        ForEach(
            swipeActions,
            id: \.id
        ) { action in
            Button {
                withAnimation {
                    actions.onSwipe(rowID, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}
