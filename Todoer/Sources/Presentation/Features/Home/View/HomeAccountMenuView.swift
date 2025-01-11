import SwiftUI
import Theme

// MARK: - HomeAccountMenuView

struct HomeAccountMenuView: View {
	private let profilePhotoUrl: String
	private let onAboutTap: () -> Void
	private let onDelteAccountTap: () -> Void
	private let onSignoupTap: () -> Void
	private let onProfilePhotoAppear: () -> Void

	init(
		profilePhotoUrl: String,
		onAboutTap: @escaping () -> Void,
		onDelteAccountTap: @escaping () -> Void,
		onSignoupTap: @escaping () -> Void,
		onProfilePhotoAppear: @escaping () -> Void
	) {
		self.profilePhotoUrl = profilePhotoUrl
		self.onAboutTap = onAboutTap
		self.onDelteAccountTap = onDelteAccountTap
		self.onSignoupTap = onSignoupTap
		self.onProfilePhotoAppear = onProfilePhotoAppear
	}

	var body: some View {
		HStack {
			Spacer()
			Menu {
				Button(Constants.Text.about) {
					onAboutTap()
				}
				Button(Constants.Text.deleteAccount, role: .destructive) {
					onDelteAccountTap()
				}
				Button(Constants.Text.logout) {
					onSignoupTap()
				}
			} label: {
				AsyncImage(
					url: URL(string: profilePhotoUrl),
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
			onProfilePhotoAppear()
		}
	}
}

// MARK: - Constants

extension HomeAccountMenuView {
	fileprivate struct Constants {
		struct Text {
			static let logout = "Logout"
			static let about = "About"
			static let deleteAccount = "Delete account"
		}
	}
}
