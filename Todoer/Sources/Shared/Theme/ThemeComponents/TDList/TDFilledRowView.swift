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
    @ObservedObject var row: TDListRow
    @State private var isDone: Bool = false
    let actions: TDFilledRowActions
    let configuration: TDFilledRowConfiguration

    var body: some View {
        Group {
            HStack {
                row.image
                    .foregroundColor(Color.buttonBlack)
                Button(action: { actions.onTap?(row.id) }) {
                    TDURLText(text: row.name)
                        .lineLimit(configuration.lineLimit)
                        .multilineTextAlignment(.leading)
                        .strikethrough(isDone)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .foregroundColor(Color.textBlack)
            }
            .frame(minHeight: 40)
        }
        .onAppear {
            isDone = row.strikethrough
        }
        .onChange(of: row.strikethrough) {
            isDone = row.strikethrough
        }
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    isDone.toggle()
                    actions.onSwipe(row.id, action)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    row.strikethrough = isDone
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}
