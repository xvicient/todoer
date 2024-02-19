import SwiftUI

struct TDRow: Identifiable {
    let id = UUID()
    var name: String
    var done: Bool
    let leadingActions: [TDSwipeAction]
    let trailingActions: [TDSwipeAction]
    var isEditing: Bool
    
    init(name: String,
         done: Bool,
         leadingActions: [TDSwipeAction] = [],
         trailingActions: [TDSwipeAction] = [],
         isEditing: Bool = false) {
        self.name = name
        self.done = done
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.isEditing = isEditing
    }
}

struct TDRowView: View {
    private let row: TDRow
    private let onTap: (() -> Void)?
    private let onSwipe: (TDSwipeAction) -> Void
    
    init(
        row: TDRow,
        onTap: (() -> Void)? = nil,
        onSwipe: @escaping (TDSwipeAction) -> Void
    ) {
        self.row = row
        self.onTap = onTap
        self.onSwipe = onSwipe
    }
    
    var body: some View {
        Group {
            HStack {
                (row.done ? Image.largecircleFillCircle : Image.circle)
                    .foregroundColor(.buttonBlack)
                Button(action: {
                    onTap?()
                }) {
                    Text(row.name)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .strikethrough(row.done)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .foregroundColor(.textBlack)
            }
            .frame(minHeight: 40)
        }
        .swipeActions(edge: .leading) {
            swipeActions(
                row.leadingActions
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(
                row.trailingActions
            )
        }
        .listRowInsets(.init(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8))
    }
    
    @ViewBuilder
    private func swipeActions(
        _ actions: [TDSwipeAction]
    ) -> some View {
        ForEach(actions,
                id: \.id) { option in
            Button {
                withAnimation {
                    onSwipe(option)
                }
            } label: {
                option.icon
            }
            .tint(option.tint)
        }
    }
}
