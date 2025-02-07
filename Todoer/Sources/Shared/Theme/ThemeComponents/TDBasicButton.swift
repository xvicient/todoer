import SwiftUI
import ThemeAssets

/// Defines the visual style of a basic button
public enum TDButtonStyle {
	case primary
	case destructive

	/// The background color of the button based on its style
	var backgroundColor: Color {
		switch self {
		case .primary:
            return Color.buttonBlack
		case .destructive:
			return Color.buttonDestructive
		}
	}

	/// The foreground color of the button based on its style
	var foregroundColor: Color {
		switch self {
		case .primary:
			return Color.textWhite
		case .destructive:
			return Color.textWhite
		}
	}
}

/// Defines the size configuration of a basic button
public enum TDButtonSize {
	case `default`
	case custom(with: CGFloat, height: CGFloat)

	/// The size value of the button based on its configuration
	var value: (CGFloat, CGFloat) {
		switch self {
		case .default:
			return (.infinity, 44)
		case .custom(let width, let height):
			return (width, height)
		}
	}
}

/// A basic button component with customizable style and size
/// Used for common actions throughout the app
public struct TDBasicButton: View {
	let title: String
	let style: TDButtonStyle
	let size: TDButtonSize
	let action: () -> Void

    /// Creates a new basic button
    /// - Parameters:
    ///   - title: The text to display in the button
    ///   - style: The visual style of the button (default: .primary)
    ///   - size: The size configuration of the button (default: .default)
    ///   - action: The action to perform when the button is tapped
    public init(
		title: String,
		style: TDButtonStyle = .primary,
		size: TDButtonSize = .default,
		action: @escaping () -> Void
	) {
		self.title = title
		self.style = style
		self.size = size
		self.action = action
	}

    public var body: some View {
		HStack {
			Button(
				action: action,
				label: {
					Text(title)
						.fontWeight(.bold)
				}
			)
			.frame(maxWidth: size.value.0)
			.frame(height: size.value.1)
			.background(style.backgroundColor)
			.foregroundColor(style.foregroundColor)
			.cornerRadius(8)
			.buttonStyle(.plain)
		}
	}
}

struct TDBasicButton_Previews: PreviewProvider {
	static var previews: some View {
		TDBasicButton(
			title: "OK",
			action: {}
		)
	}
}
