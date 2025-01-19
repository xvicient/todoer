import SwiftUI
import ThemeAssets
import ThemeComponents
import Application

// MARK: - InvitationsView

struct InvitationsView: View {
    @ObservedObject private var store: Store<Invitations.Reducer>

    init(store: Store<Invitations.Reducer>) {
        self.store = store
    }

	var body: some View {
		Section(header: Text(Constants.Text.invitations).listRowHeaderStyle()) {
            ForEach(store.state.viewModel.invitations) { invitation in
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
						TDBasicButton(
							title: "\(Constants.Text.accept)",
							style: .primary,
							size: .custom(with: 100, height: 32)
						) {
                            store.send(
                                .didTapAcceptInvitation(
                                    invitation.listId,
                                    invitation.documentId
                                )
                            )
						}
						TDBasicButton(
							title: "\(Constants.Text.decline)",
							style: .destructive,
							size: .custom(with: 100, height: 32)
						) {
                            store.send(
                                .didTapDeclineInvitation(
                                    invitation.listId,
                                    invitation.documentId
                                )
                            )
						}
					}
				}
			}
		}
        .onAppear {
            store.send(.onViewAppear)
        }
	}
}

// MARK: - Constants

extension InvitationsView {
	fileprivate struct Constants {
		struct Text {
			static let invitations = "Invitations"
			static let wantsToShare = "Wants to share: "
			static let accept = "Accept"
			static let decline = "Decline"
		}
	}
}
