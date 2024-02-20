import SwiftUI

// MARK: - TDOptionsMenuView

struct TDOptionsMenuView: View {
	private let onSort: () -> Void

	init(
		onSort: @escaping () -> Void
	) {
		self.onSort = onSort
	}

	var body: some View {
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
					.foregroundColor(.buttonBlack)
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
