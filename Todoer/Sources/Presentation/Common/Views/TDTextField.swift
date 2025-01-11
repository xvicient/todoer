import SwiftUI
import Theme

struct TDTextField: View {
	@Binding var text: String
	let placeholder: String

	init(text: Binding<String>, placeholder: String) {
		_text = text
		self.placeholder = placeholder
	}

	var body: some View {
		ZStack {
			HStack {
				TextField(placeholder, text: $text)
                    .background(Color.backgroundWhite)
					.padding(.vertical, 10)
					.padding(.leading, 12)
					.padding(.trailing, 32)
					.foregroundColor(Color.textSecondary)
					.overlay(
						RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.borderBlack, lineWidth: 1)
					)
			}
			if !text.isEmpty {
				HStack {
					Spacer()
					Button(action: {
						text = ""
					}) {
						Image.multiplyCircleFill
							.resizable()
							.frame(width: 14, height: 14)
							.foregroundColor(Color.textSecondary)
							.padding(8)
							.padding(.trailing, 4)
					}
				}
			}
		}
	}
}
