import SwiftUI
import Application
import Common
import ThemeAssets
import AppMenuContract

// MARK: - MenuView

struct AppMenuView: View {
    @ObservedObject private var store: Store<AppMenu.Reducer>

    init(store: Store<AppMenu.Reducer>) {
        self.store = store
    }

	var body: some View {
		HStack {
			Spacer()
			Menu {
				Button(Constants.Text.about) {
                    store.send(.didTapAboutButton)
				}
				Button(Constants.Text.deleteAccount, role: .destructive) {
                    store.send(.didTapDeleteAccountButton)
				}
				Button(Constants.Text.logout) {
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

// MARK: - Constants

extension AppMenuView {
	fileprivate struct Constants {
		struct Text {
			static let logout = "Logout"
			static let about = "About"
			static let deleteAccount = "Delete account"
		}
	}
}
