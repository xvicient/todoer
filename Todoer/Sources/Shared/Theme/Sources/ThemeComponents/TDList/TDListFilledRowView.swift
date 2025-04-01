import SwiftUI
import ThemeAssets

protocol TDListFilledRowActions {
    var onTap: ((UUID) -> Void)? { get }
    var onSwipe: (UUID, TDListSwipeAction) -> Void { get }
}

protocol TDListFilledRowConfiguration {
    var lineLimit: Int? { get }
    var isSwipeEnabled: Bool { get }
}

struct TDListFilledRowView: View {
    var row: TDListRow
    let actions: TDListFilledRowActions
    let configuration: TDListFilledRowConfiguration

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            Button(action: { actions.onTap?(row.id) }) {
                TDURLText(text: row.name)
                    .lineLimit(configuration.lineLimit)
                    .multilineTextAlignment(.leading)
                    .strikethrough(row.done)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.textBlack)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .frame(minHeight: 40)
        .if(configuration.isSwipeEnabled) {
            $0.swipeActions(edge: .leading, allowsFullSwipe: true) {
                swipeActions(row, row.leadingActions)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                swipeActions(row, row.trailingActions)
            }
        }
    }

    @ViewBuilder
    private func swipeActions(
        _ row: TDListRow,
        _ swipeActions: [TDListSwipeAction]
    ) -> some View {
        ForEach(swipeActions) { action in
            Button(role: action.role) {
                switch action {
                case .done, .undone, .delete:
                    withAnimation(.easeInOut(duration: 0.2)) {
                        actions.onSwipe(row.id, action)
                    }
                case .share:
                    actions.onSwipe(row.id, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}
