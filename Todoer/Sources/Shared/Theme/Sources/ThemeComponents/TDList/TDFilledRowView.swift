import SwiftUI
import ThemeAssets

protocol TDFilledRowActions {
    var onTap: ((UUID) -> Void)? { get }
    var onSwipe: (UUID, TDSwipeAction) -> Void { get }
}

protocol TDFilledRowConfiguration {
    var lineLimit: Int? { get }
    var isSwipeEnabled: Bool { get }
}

struct TDFilledRowView: View {
    var row: TDListRow
    let actions: TDFilledRowActions
    let configuration: TDFilledRowConfiguration

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            Button(action: { actions.onTap?(row.id) }) {
                TDURLText(text: row.name)
                    .lineLimit(configuration.lineLimit)
                    .multilineTextAlignment(.leading)
                    .strikethrough(row.strikethrough)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.textBlack)
        }
        .frame(minHeight: 40)
        .if(configuration.isSwipeEnabled) {
            $0.swipeActions(edge: .leading) {
                swipeActions(row, row.leadingActions)
            }
        }
        .if(configuration.isSwipeEnabled) {
            $0.swipeActions(edge: .trailing) {
                swipeActions(row, row.trailingActions)
            }
        }
    }

    @ViewBuilder
    private func swipeActions(
        _ row: TDListRow,
        _ swipeActions: [TDSwipeAction]
    ) -> some View {
        ForEach(swipeActions) { action in
            Button(role: action.role) {
                switch action {
                case .done, .undone, .delete:
                    withAnimation(.easeInOut(duration: 0.2)) {
                        actions.onSwipe(row.id, action)
                    }
                case .edit, .share:
                    actions.onSwipe(row.id, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}
