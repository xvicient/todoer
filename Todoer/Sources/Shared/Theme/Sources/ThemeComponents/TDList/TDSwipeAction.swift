import SwiftUI
import ThemeAssets

public enum TDSwipeAction: Identifiable, Sendable {
    case share
    case done
    case undone
    case delete

    public var id: UUID { UUID() }

    var tint: Color {
        switch self {
        case .share: return Color.buttonBlack
        case .done: return Color.buttonBlack
        case .undone: return Color.buttonBlack
        case .delete: return Color.buttonDestructive
        }
    }

    var icon: Image {
        switch self {
        case .share: return Image.squareAndArrowUp
        case .done: return Image.largecircleFillCircle
        case .undone: return Image.circle
        case .delete: return Image.trash
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete: return .destructive
        default: return nil
        }
    }
}
