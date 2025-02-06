import SwiftUI
import ThemeAssets

public struct TDListSectionButton: View {
    private let onTap: () -> Void
    private let title: String
    private let icon: Image
    
    public init(
        title: String,
        icon: Image,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 8) {
                icon
                    .resizable()
                    .frame(width: 21.0, height: 21.0)
                    .foregroundColor(Color.textBlack)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.backgroundWhite)
                    )
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.textBlack)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 50)
            .padding(.horizontal, 10)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 100, height: 50)
        .applyButtonBackground()
        .applyButtonOverlay()
        .contentShape(Rectangle())
    }
}

// MARK: - View Modifiers

private struct ButtonBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height

                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.backgroundWhite)
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: width, y: 0))
                                    path.addLine(to: CGPoint(x: width, y: height))
                                    path.addLine(to: CGPoint(x: 0, y: height))
                                    path.closeSubpath()
                                }
                                .fill(Color.backgroundSecondary.opacity(0.25))
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            )
    }
}

private struct ButtonOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderBlack, lineWidth: 1)
            )
    }
}

extension View {
    func applyButtonBackground() -> some View {
        self.modifier(ButtonBackground())
    }

    func applyButtonOverlay() -> some View {
        self.modifier(ButtonOverlay())
    }
}

struct TDActionButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TDListSectionButton(title: "New To-do", icon: Image.plusCircleFill) {}
            TDListSectionButton(title: "Sort", icon: Image.plusCircleFill) {}
        }
    }
}
