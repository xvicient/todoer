import SwiftUI

struct BottomLineStyle: TextFieldStyle {
    var action: () -> Void
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack() {
            HStack {
                configuration
                    .submitLabel(.send)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                Button(action: action,
                       label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24.0, height: 24.0)
                })
                .foregroundColor(.buttonPrimary)
            }
            Rectangle()
                .frame(height: 1.0, alignment: .bottom)
                .foregroundColor(.buttonPrimary)
        }
        .padding(24)
    }
}
