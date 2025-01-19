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
        .alert(item: alertBinding) {
            alert(for: $0)
        }
	}
}

extension AppMenuView {    
    fileprivate var alertBinding: Binding<AlertStyle?> {
        Binding(
            get: {
                guard case .alert(let data) = store.state.viewState else {
                    return nil
                }
                return data
            },
            set: { _ in }
        )
    }
    
    fileprivate func alert(for style: AlertStyle) -> Alert {
        switch style {
        case let .error(message):
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: Text(message),
                dismissButton: .default(Text(Constants.Text.okButton)) {
                    store.send(.didTapDismissError)
                }
            )
        case .destructive:
            Alert(
                title: Text(""),
                message: Text(Constants.Text.deleteAccountConfirmation),
                primaryButton: .destructive(Text(Constants.Text.deleteButton)) {
                    store.send(.didTapConfirmDeleteAccount)
                },
                secondaryButton: .default(Text(Constants.Text.cancelButton)) {
                    store.send(.didTapDismissDeleteAccount)
                }
            )
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
            static let deleteAccountConfirmation = "This action will delete your account and data. Are you sure?"
            static let deleteButton = "Delete"
            static let cancelButton = "Cancel"
            static let errorTitle = "Error"
            static let okButton = "Ok"
		}
	}
}
