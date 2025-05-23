import AppMenuContract
import Common
import Strings
import SwiftUI
import ThemeAssets
import xRedux

/// A view that displays the application menu with user profile and options
struct AppMenuView: View {

    /// Store that manages the menu state and action
    @Bindable private var store: Store<AppMenu.Reducer>

    /// Initializes the menu view with a store
    /// - Parameter store: The store that manages the menu state
    init(store: Store<AppMenu.Reducer>) {
        self.store = store
    }

    var body: some View {
        HStack {
            Spacer()
            Menu {
                Button(Strings.AppMenu.aboutOptionTitle) {
                    store.send(.didTapAboutButton)
                }
                Button(Strings.AppMenu.deleteAccountOptionTitle, role: .destructive) {
                    store.send(.didTapDeleteAccountButton)
                }
                Button(Strings.AppMenu.logoutOptionTitle) {
                    store.send(.didTapSignoutButton)
                }
            } label: {
                AsyncImage(
                    url: URL(string: store.state.viewModel.photoUrl),
                    content: {
                        $0.resizable().aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        Image.personCropCircle
                            .tint(Color.buttonBlack)
                    }
                )
                .frame(width: 30, height: 30)
                .cornerRadius(15.0)
            }
        }
        .onAppear {
            store.send(.onViewAppear)
        }
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}
