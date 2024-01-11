import SwiftUI

struct TDTitle: View {
    let title: String
    let image: Image?
    
    init(title: String, image: Image? = nil) {
        self.title = title
        self.image = image
    }
    
    var body: some View {
        HStack {
            if let image = image{
                image
            }
            Text(title)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

struct TDTitle_Previews: PreviewProvider {
    static var previews: some View {
        TDButton(title: "OK",
                 action: {})
    }
}
