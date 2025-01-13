import SwiftUI
import ThemeAssets

public struct TDNewRowButton: View {
    private let onTap: () -> Void
    private let title: String
    
    public init(
        title: String,
        onTap: @escaping () -> Void
    ) {
        self.title = title
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
                    Image.plusCircleFill
                        .resizable()
                        .frame(width: 21.0, height: 21.0)
                        .foregroundColor(Color.textBlack)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.backgroundWhite)
                        )
                    Spacer()
                    Text(title)
                        .font(.system(size: 18))
                        .foregroundColor(Color.textBlack)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 12)
                .padding(.horizontal, 10)
                Spacer()
                HStack {
                    Spacer()
                    Image.todo
                        .resizable()
                        .frame(width: 50.0, height: 50.0)
                        .tint(Color.backgroundWhite)
                }
                .padding(.top, -8)
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
        TDNewRowButton(title: "New To-do") {}
    }
}
