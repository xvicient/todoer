import SwiftUI

struct TDRow: View {
    private let row: Home.Reducer.ListRow
    private let tapHandler: (() -> Void)?
    private let swipeHandler: (TDSwipeActionOption) -> Void
    
    init(
        row: Home.Reducer.ListRow,
        tapHandler: (() -> Void)? = nil,
        swipeHandler: @escaping (TDSwipeActionOption) -> Void
    ) {
        self.row = row
        self.tapHandler = tapHandler
        self.swipeHandler = swipeHandler
    }
    
    var body: some View {
        Group {
            HStack {
                (row.list.done ? Image.largecircleFillCircle : Image.circle)
                    .foregroundColor(.buttonBlack)
                Button(action: {
                    tapHandler?()
                }) {
                    Text(row.list.name)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .strikethrough(row.list.done)
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
        .id(row.id)
    }
    
    @ViewBuilder
    private func swipeActions(
        _ actions: [TDSwipeActionOption]
    ) -> some View {
        ForEach(actions,
                id: \.id) { option in
            Button {
                withAnimation {
                    swipeHandler(option)
                }
            } label: {
                option.icon
            }
            .tint(option.tint)
        }
    }
}
