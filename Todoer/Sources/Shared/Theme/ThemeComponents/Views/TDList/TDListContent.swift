import SwiftUI
import Common

public struct TDListContent: View {
    private let rows: [TDListRow]
    private let isMoveAllowed: Bool
    private let onSubmit: (String) -> Void
    private let onUpdate: (UUID, String) -> Void
    private let onCancelAdd: () -> Void
    private let onCancelEdit: (UUID) -> Void
    private let onTap: ((UUID) -> Void)?
    private let onSwipe: (UUID, TDSwipeAction) -> Void
    private let onMove: (IndexSet, Int) -> Void
    
    @FocusState private var isEmptyRowFocused: Bool
    @State private var emptyRowText = ""
    
    public init(
        rows: [TDListRow],
        isMoveAllowed: Bool,
        onSubmit: @escaping (String) -> Void,
        onUpdate: @escaping (UUID, String) -> Void,
        onCancelAdd: @escaping () -> Void,
        onCancelEdit: @escaping (UUID) -> Void,
        onTap: ((UUID) -> Void)? = nil,
        onSwipe: @escaping (UUID, TDSwipeAction) -> Void,
        onMove: @escaping (IndexSet, Int) -> Void
    ) {
        self.rows = rows
        self.isMoveAllowed = isMoveAllowed
        self.onSubmit = onSubmit
        self.onUpdate = onUpdate
        self.onCancelAdd = onCancelAdd
        self.onCancelEdit = onCancelEdit
        self.onTap = onTap
        self.onSwipe = onSwipe
        self.onMove = onMove
    }
    
    public var body: some View {
        ForEach(
            Array(rows.enumerated()),
            id: \.element.id
        ) { index, row in
            if row.isEditing {
                emptyRow(row)
                .id(index)
            } else {
                filledRow(row)
                .id(index)
            }
        }
        .if(isMoveAllowed) {
            $0.onMove(perform: onMove)
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
            TextField(Constants.Text.list, text: $emptyRowText)
                .foregroundColor(Color.textBlack)
                .focused($isEmptyRowFocused)
                .onAppear {
                    emptyRowText = row.name
                }
                .onSubmit {
                    hideKeyboard()
                    if row.name.isEmpty {
                        onSubmit($emptyRowText.wrappedValue)
                    }
                    else {
                        onUpdate(row.id, $emptyRowText.wrappedValue)
                    }
                }
                .submitLabel(.done)
            Button(action: {
                hideKeyboard()
                if row.name.isEmpty {
                    onCancelAdd()
                }
                else {
                    onCancelEdit(row.id)
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
                    onTap?(row.id)
                }) {
                    Text(row.name)
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
        _ actions: [TDSwipeAction]
    ) -> some View {
        ForEach(
            actions,
            id: \.id
        ) { action in
            Button {
                withAnimation {
                    onSwipe(rowID, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}

private extension TDListContent {
    struct Constants {
        struct Text {
            static let list = "Name..."
        }
    }
}
