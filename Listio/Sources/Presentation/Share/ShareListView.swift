import SwiftUI

struct ShareListView: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            TDTitle(title: "Share",
                    image: Image(systemName: "square.and.arrow.up"))
            TDTextField(placeholder: "Email...")
            TDButton(title: "Share") {
                
            }
            .padding(.horizontal, 24)
            TDTitle(title: "Sharing with...")
            SwiftUI.List {
                ForEach(store.state.users,
                        id: \.uuid) { user in
                    Text(user.displayName ?? "")
                }
            }
        }
        .padding(.top, 24)
        .onAppear {
            store.send(.viewWillAppear)
        }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareList.Builder.makeShareList(listUids: [])
    }
}
