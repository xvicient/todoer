import SwiftUI

struct ShareListView: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareEmailText: String = ""
    
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 12) {
            TDTitle(title: Constants.Text.shareTitle,
                    image: .squareAndArrowUp)
            TDTextField(text: $shareEmailText,
                        placeholder: Constants.Text.sharePlaceholder)
            TDButton(title: Constants.Text.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue))
            }
            .padding(.horizontal, 24)
            SwiftUI.List(store.state.users) { user in
                Section(
                    header:
                        Text(Constants.Text.sharingWithTitle)
                        .foregroundColor(.textPrimary)
                ) {
                    Text(user.displayName ?? "")
                        .foregroundColor(.textPrimary)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
        }
        .padding(.top, 24)
        .frame(maxHeight: .infinity)
        .background(.backgroundWhite)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Constants

private extension ShareListView {
    struct Constants {
        struct Text {
            static let shareTitle = "Share"
            static let sharingWithTitle = "Sharing with"
            static let shareButtonTitle = "Share"
            static let sharePlaceholder = "Email..."
        }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareList.Builder.makeShareList(
            coordinator: Coordinator(),
            list: List(
                documentId: "",
                name: "",
                done: true,
                uuid: [],
                dateCreated: 0
            )
        )
    }
}
