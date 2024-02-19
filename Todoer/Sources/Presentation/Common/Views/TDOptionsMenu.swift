import SwiftUI

// MARK: - TDOptionsMenu

struct TDOptionsMenu: View {
    private let sortHandler: () -> Void
    
    init(
        sortHandler: @escaping () -> Void
    ) {
        self.sortHandler = sortHandler
    }
    
    var body: some View {
        HStack {
            Spacer()
            Menu {
                Button(Constants.Text.autoSort) {
                    withAnimation {
                        sortHandler()
                    }
                }
            } label: {
                Image.ellipsis
                    .resizable()
                    .scaleEffect(0.75)
                    .rotationEffect(Angle(degrees: 90))
                    .foregroundColor(.buttonBlack)
            }
        }    }
}

// MARK: - Constants

private extension TDOptionsMenu {
    struct Constants {
        struct Text {
            static let autoSort = "To-do first"
        }
    }
}
