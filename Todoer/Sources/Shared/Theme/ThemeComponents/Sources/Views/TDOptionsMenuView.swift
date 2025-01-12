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
            Menu {
                Button(Constants.Text.autoSort) {
                    withAnimation {
                        onSort()
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Image.ellipsis
                        .resizable()
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(Color.buttonBlack)
                        .scaledToFit()
                        .frame(width: 15)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 40, height: 40)
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

struct TDOptionsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TDOptionsMenuView {}
    }
}
