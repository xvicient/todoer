import SwiftUI
import Data
import ThemeAssets
import ThemeComponents

// MARK: - HomeInvitationsView

struct HomeInvitationsView: View {
	private let invitations: [Invitation]
	private let onAccept: (String, String) -> Void
	private let onDecline: (String) -> Void

	init(
		invitations: [Invitation],
		onAccept: @escaping (String, String) -> Void,
		onDecline: @escaping (String) -> Void
	) {
		self.invitations = invitations
		self.onAccept = onAccept
		self.onDecline = onDecline
	}

	var body: some View {
		Section(header: Text(Constants.Text.invitations).listRowHeaderStyle()) {
			ForEach(invitations) { invitation in
				HStack {
					VStack(alignment: .leading) {
						Text("\(invitation.ownerName)")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(Color.textBlack)
						if !invitation.ownerEmail.isEmpty {
							Text("(\(invitation.ownerEmail))")
								.font(.system(size: 14, weight: .light))
								.padding(.bottom, 8)
						}
						Text("\(Constants.Text.wantsToShare)")
							.font(.system(size: 14))
						Text("\(invitation.listName)")
							.font(.system(size: 14, weight: .bold))
							.foregroundColor(Color.textSecondary)
					}
					Spacer()
					VStack {
						TDButton(
							title: "\(Constants.Text.accept)",
							style: .primary,
							size: .custom(with: 100, height: 32)
						) {
							onAccept(
								invitation.listId,
								invitation.documentId
							)
						}
						TDButton(
							title: "\(Constants.Text.decline)",
							style: .destructive,
							size: .custom(with: 100, height: 32)
						) {
							onDecline(invitation.documentId)
						}
					}
				}
			}
		}
	}
}

// MARK: - Constants

extension HomeInvitationsView {
	fileprivate struct Constants {
		struct Text {
			static let invitations = "Invitations"
			static let wantsToShare = "Wants to share: "
			static let accept = "Accept"
			static let decline = "Decline"
		}
	}
}
