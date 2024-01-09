import SwiftUI

struct ShareListView: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareEmailText: String = ""
    
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            TDTitle(title: Constants.Text.shareTitle,
                    image: Image(systemName: Constants.Image.share))
            TDTextField(text: $shareEmailText,
                        placeholder: Constants.Text.sharePlaceholder)
            TDButton(title: Constants.Text.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue))
            }
            .padding(.horizontal, 24)
            TDTitle(title: Constants.Text.sharingWithTitle)
            SwiftUI.List {
                ForEach(store.state.users,
                        id: \.uuid) { user in
                    Text(user.displayName ?? "")
                }
            }
        }
        .padding(.top, 24)
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
        struct Image {
            static let share = "square.and.arrow.up"
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
