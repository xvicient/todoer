import SwiftUI
import ThemeAssets

public enum TDButtonStyle {
    case primary
    case destructive

    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color.buttonBlack
        case .destructive:
            return Color.buttonDestructive
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary:
            return Color.textWhite
        case .destructive:
            return Color.textWhite
        }
    }
}

public enum TDButtonSize {
    case `default`
    case custom(with: CGFloat, height: CGFloat)

    var value: (CGFloat, CGFloat) {
        switch self {
        case .default:
            return (.infinity, 44)
        case .custom(let width, let height):
            return (width, height)
        }
    }
}

public struct TDBasicButton: View {
    let title: String
    let style: TDButtonStyle
    let size: TDButtonSize
    let action: () -> Void

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

struct TOButton_Previews: PreviewProvider {
    static var previews: some View {
        TDBasicButton(
            title: "OK",
            action: {}
        )
    }
}
