import SwiftUI

struct TDTextField: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String) {
        _text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            HStack {
                TextField(placeholder, text: $text)
                    .background(.backgroundWhite)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.borderSecondary, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            if !text.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        text = ""
                    }) {
                        Image.multiplyCircleFill
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.textSecondary)
                            .padding(8)
                            .padding(.trailing, 24)
                    }
                }
            }
        }
    }
}
