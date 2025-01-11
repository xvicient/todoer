import SwiftUI
import ThemeAssets

// MARK: - TDOptionsMenuView

public struct TDOptionsMenuView: View {
	private let onSort: () -> Void

    public init(
		onSort: @escaping () -> Void
	) {
		self.onSort = onSort
	}

    public var body: some View {
		HStack {
			Spacer()
			Menu {
				Button(Constants.Text.autoSort) {
					withAnimation {
						onSort()
					}
				}
			} label: {
				Image.ellipsis
					.resizable()
					.scaleEffect(0.75)
					.rotationEffect(Angle(degrees: 90))
					.foregroundColor(Color.buttonBlack)
			}
		}
	}
}

// MARK: - Constants

extension TDOptionsMenuView {
	fileprivate struct Constants {
		struct Text {
			static let autoSort = "To-do first"
		}
	}
}
