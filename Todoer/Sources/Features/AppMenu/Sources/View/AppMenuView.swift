import SwiftUI
import Application
import Common
import ThemeAssets
import AppMenuContract
import Strings

// MARK: - MenuView

/// A view that displays the application menu with user profile and options
struct AppMenuView: View {
    /// Store that manages the menu state and actions
    @ObservedObject private var store: Store<AppMenu.Reducer>

    /// Initializes the menu view with a store
    /// - Parameter store: The store that manages the menu state
    init(store: Store<AppMenu.Reducer>) {
        self.store = store
    }

    /// The body of the view that constructs the menu interface
    var body: some View {
        HStack {
            Spacer()
            Menu {
                // About option
                Button(Strings.AppMenu.aboutOptionTitle) {
                    store.send(.didTapAboutButton)
                }
                // Delete account option with destructive role
                Button(Strings.AppMenu.deleteAccountOptionTitle, role: .destructive) {
                    store.send(.didTapDeleteAccountButton)
                }
                // Logout option
                Button(Strings.AppMenu.logoutOptionTitle) {
                    store.send(.didTapSignoutButton)
                }
            } label: {
                // Menu button with user profile picture
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
        // View lifecycle and state handling
        .onAppear {
            store.send(.onViewAppear)
        }
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}
