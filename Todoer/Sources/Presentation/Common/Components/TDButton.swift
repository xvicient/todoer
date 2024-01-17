import SwiftUI

enum TDButtonStyle {
    case primary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .buttonPrimary
        case .destructive:
            return .buttonDestructive
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .textAccent
        case .destructive:
            return .textWhite
        }
    }
}

enum TDButtonSize {
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

struct TDButton: View {
    let title: String
    let style: TDButtonStyle
    let size: TDButtonSize
    let action: () -> Void
    
    init(
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
    
    var body: some View {
        HStack {
            Button(action: action,
                   label: {
                Text(title)
                    .fontWeight(.bold)
            })
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
        TDButton(title: "OK",
                 action: {})
    }
}
