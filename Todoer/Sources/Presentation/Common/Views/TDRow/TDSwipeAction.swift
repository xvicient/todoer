import SwiftUI
import Theme

enum TDSwipeAction: Identifiable {
	case share
	case done
	case undone
	case delete
	case edit

	var id: UUID { UUID() }

	var tint: Color {
		switch self {
		case .share: return Color.buttonBlack
		case .done: return Color.buttonBlack
		case .undone: return Color.buttonBlack
		case .delete: return Color.buttonDestructive
		case .edit: return Color.buttonSecondary
		}
	}

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
