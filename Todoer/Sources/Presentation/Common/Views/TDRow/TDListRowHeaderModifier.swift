import SwiftUI
import Theme

struct TDListRowHeaderModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.textCase(nil)
			.font(.title)
			.foregroundColor(Color.textBlack)
			.listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
	}
}

extension View {
	func listRowHeaderStyle() -> some View {
		modifier(TDListRowHeaderModifier())
	}
}
