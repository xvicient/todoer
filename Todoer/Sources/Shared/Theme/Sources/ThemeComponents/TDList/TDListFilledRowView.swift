import SwiftUI
import ThemeAssets

protocol TDListFilledRowActions {
    var onTap: ((String) -> Void)? { get }
    var onSwipe: (String, TDListSwipeAction) -> Void { get }
}

struct TDListFilledRowView: View {
    var row: TDListRow
    let actions: TDListFilledRowActions

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            Button(action: { actions.onTap?(row.id) }) {
                TDURLText(text: row.name)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .strikethrough(row.done)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.textBlack)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .frame(minHeight: 40)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            swipeActions(row, row.leadingActions)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(row, row.trailingActions)
        }
    }

    @ViewBuilder
    private func swipeActions(
        _ row: TDListRow,
        _ swipeActions: [TDListSwipeAction]
    ) -> some View {
        ForEach(swipeActions) { action in
            Button(role: action.role) {
                withAnimation {
                    actions.onSwipe(row.id, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}
