import SwiftUI
import ThemeAssets

/// A custom action button component that displays a title and an icon with a specific visual style.
/// Used for primary actions in the app like creating new items or sorting.
public struct TDActionButton: View {
    private let onTap: () -> Void
    private let title: String
    private let icon: Image
    
    /// Creates a new action button with the specified title and icon
    /// - Parameters:
    ///   - title: The text to display in the button
    ///   - icon: The icon image to show above the title
    ///   - onTap: The action to perform when the button is tapped
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
            withAnimation {
                onTap()
            }
        }) {
            VStack {
                HStack {
                    icon
                        .resizable()
                        .frame(width: 21.0, height: 21.0)
                        .foregroundColor(Color.textBlack)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.backgroundWhite)
                        )
                    Text(title)
                        .font(.system(size: 18))
                        .foregroundColor(Color.textBlack)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(height: 50)
                .padding(.top, 6)
                .padding(.horizontal, 10)
                HStack {
                    Spacer()
                    Image.checklistUnchecked
                        .resizable()
                        .frame(width: 20.0, height: 20.0)
                        .tint(Color.backgroundWhite)
                }
                .padding(.bottom, 4)
                .padding(.trailing, 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 100, height: 100)
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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.borderBlack, lineWidth: 1)
        )
    }
}

struct TDNewRowButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TDActionButton(title: "New To-do", icon: Image.plusCircleFill) {}
            TDActionButton(title: "Sort", icon: Image.plusCircleFill) {}
        }
    }
}
