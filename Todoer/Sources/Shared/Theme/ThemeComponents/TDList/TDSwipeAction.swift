import SwiftUI
import ThemeAssets

/// Represents different types of swipe actions available for list rows
/// Each action has an associated tint color and icon
public enum TDSwipeAction: Identifiable, Sendable {
	case share
	case done
	case undone
	case delete
	case edit

	/// The unique identifier for the action
	public var id: UUID { UUID() }

	/// The tint color to use for the action button
	var tint: Color {
		switch self {
		case .share: return Color.buttonBlack
		case .done: return Color.buttonBlack
		case .undone: return Color.buttonBlack
		case .delete: return Color.buttonDestructive
		case .edit: return Color.buttonSecondary
		}
	}

	/// The icon to display for the action button
	var icon: Image {
		switch self {
		case .share: return Image.squareAndArrowUp
		case .done: return Image.largecircleFillCircle
		case .undone: return Image.circle
		case .delete: return Image.trash
		case .edit: return Image.squareAndPencil
		}
	}
}
