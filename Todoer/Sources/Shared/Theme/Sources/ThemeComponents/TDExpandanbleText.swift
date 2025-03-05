import SwiftUI

public struct TDExpandableText: View {
    let text: String
    let limit: Int
    
    @State private var isExpanded = false
    @State private var canBeExpanded = false
    @State private var truncatedSize: CGSize = .zero
    @State private var sheetHeight: CGFloat = 100
    
    public init(text: String, limit: Int) {
        self.text = text
        self.limit = limit
    }
    
    public var body: some View {
        if canBeExpanded {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                textView
                    .font(.largeTitle.bold())
            }
            .sheet(isPresented: $isExpanded) {
                VStack {
                    Text(text)
                        .lineLimit(nil)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                sheetHeight = geometry.size.height > sheetHeight ? geometry.size.height : sheetHeight
                            }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: sheetHeight, alignment: .center)
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 15)
                )
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(0)
                .presentationBackground(.clear)
                .interactiveDismissDisabled(false)
            }
        } else {
            textView
                .font(.largeTitle.bold())
        }
    }
    
    var textView: some View {
        Text(text)
            .lineLimit(isExpanded ? nil : limit)
            .readSize { size in
                truncatedSize = size
            }
            .background {
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        canBeExpanded = truncatedSize != size
                    }
            }
    }
}

private extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
