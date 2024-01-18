import SwiftUI

struct BottomLineStyle: TextFieldStyle {
    var action: () -> Void
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            VStack {
                HStack {
                    configuration
                        .submitLabel(.send)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                Rectangle()
                    .frame(height: 1.0, alignment: .bottom)
                    .foregroundColor(.buttonBlack)
            }
            .padding(24)
            Button("Add",
                   action: action)
            .foregroundColor(.buttonBlack)
        }
    }
}
