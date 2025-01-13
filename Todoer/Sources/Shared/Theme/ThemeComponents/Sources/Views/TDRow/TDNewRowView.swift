import SwiftUI
import ThemeAssets
import Common

public struct TDNewRowView: View {
	private let row: TDRow
	private let onSubmit: (String) -> Void
	private let onUpdate: (String) -> Void
	private let onCancelAdd: () -> Void
	private let onCancelEdit: () -> Void
	@FocusState private var isNewRowFocused: Bool
	@State private var newRowText = ""

    public init(
		row: TDRow,
		onSubmit: @escaping (String) -> Void,
		onUpdate: @escaping (String) -> Void,
		onCancelAdd: @escaping () -> Void,
		onCancelEdit: @escaping () -> Void
	) {
		self.row = row
		self.onSubmit = onSubmit
		self.onUpdate = onUpdate
		self.onCancelAdd = onCancelAdd
		self.onCancelEdit = onCancelEdit
	}

    public var body: some View {
		HStack {
			row.image
				.foregroundColor(Color.buttonBlack)
			TextField(Constants.Text.list, text: $newRowText)
				.foregroundColor(Color.textBlack)
				.focused($isNewRowFocused)
				.onAppear {
					newRowText = row.name
				}
				.onSubmit {
					hideKeyboard()
					if row.name.isEmpty {
						onSubmit($newRowText.wrappedValue)
					}
					else {
						onUpdate($newRowText.wrappedValue)
					}
				}
				.submitLabel(.done)
			Button(action: {
				hideKeyboard()
				if row.name.isEmpty {
					onCancelAdd()
				}
				else {
					onCancelEdit()
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
			isNewRowFocused = true
		}
	}
}

// MARK: - TDNewRow

extension TDNewRowView {
	fileprivate struct Constants {
		struct Text {
			static let list = "Name..."
		}
	}
}
