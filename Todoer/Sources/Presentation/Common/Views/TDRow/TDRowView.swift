import SwiftUI
import Theme

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
				row.image
					.foregroundColor(Color.buttonBlack)
				Button(action: {
					onTap?()
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
				row.leadingActions
			)
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			swipeActions(
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
	private func swipeActions(
		_ actions: [TDSwipeAction]
	) -> some View {
		ForEach(
			actions,
			id: \.id
		) { option in
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
