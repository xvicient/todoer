import SwiftUI

struct TDTextField: View {
    @State private var text = ""
    let placeholder: String
    
    var body: some View {
        ZStack {
            HStack {
                TextField(placeholder, text: $text)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
            }
            if !text.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color(UIColor.darkGray))
                            .padding(8)
                            .padding(.trailing, 24)
                    }
                }
            }
        }
    }
}

struct ClearTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TDTextField(placeholder: "Email...")
    }
}
