import SwiftUI

enum TDSwipeAction: Identifiable {
	case share
	case done
	case undone
	case delete
	case edit

	var id: UUID { UUID() }

	var tint: Color {
		switch self {
		case .share: return .buttonBlack
		case .done: return .buttonBlack
		case .undone: return .buttonBlack
		case .delete: return .buttonDestructive
		case .edit: return .buttonSecondary
		}
	}

	var icon: Image {
		switch self {
		case .share: return .squareAndArrowUp
		case .done: return .largecircleFillCircle
		case .undone: return .circle
		case .delete: return .trash
		case .edit: return .squareAndPencil
		}
	}
}
