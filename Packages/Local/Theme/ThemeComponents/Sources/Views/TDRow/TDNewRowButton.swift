import SwiftUI
import ThemeAssets

public struct TDNewRowButton: View {
	private let onTap: () -> Void

    public init(
		onTap: @escaping () -> Void
	) {
		self.onTap = onTap
	}

    public var body: some View {
		VStack {
			Spacer()
			Button(
				action: {
					withAnimation {
						onTap()
					}
				},
				label: {
					Image.plusCircleFill
						.resizable()
						.frame(width: 42.0, height: 42.0)
						.foregroundColor(Color.textBlack)
						.background(
							RoundedRectangle(cornerRadius: 24)
								.fill(Color.backgroundWhite)
						)
				}
			)
		}
	}
}
