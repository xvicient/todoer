import SwiftUI

struct TDButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action,
                   label: {
                Text(title)
                    .fontWeight(.bold)
            })
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.backgroundPrimary)
            .foregroundColor(.buttonPrimary)
            .cornerRadius(8)
        }
    }
}

struct TOButton_Previews: PreviewProvider {
    static var previews: some View {
        TDButton(title: "OK", action: {})
    }
}
