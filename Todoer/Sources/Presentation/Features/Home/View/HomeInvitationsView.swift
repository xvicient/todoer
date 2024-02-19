import SwiftUI

// MARK: - HomeInvitationsView

struct HomeInvitationsView: View {
    private let invitations: [Invitation]
    private let acceptHandler: (String, String) -> Void
    private let declineHandler: (String) -> Void
    
    init(
        invitations: [Invitation],
        acceptHandler: @escaping (String, String) -> Void,
        declineHandler: @escaping (String) -> Void
    ) {
        self.invitations = invitations
        self.acceptHandler = acceptHandler
        self.declineHandler = declineHandler
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(Constants.Text.invitations)
                .font(.title3)
                .foregroundColor(.textBlack)
            
            ForEach(invitations) { invitation in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(invitation.ownerName)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textBlack)
                        if !invitation.ownerEmail.isEmpty {
                            Text("(\(invitation.ownerEmail))")
                                .font(.system(size: 14, weight: .light))
                                .padding(.bottom, 8)
                        }
                        Text("\(Constants.Text.wantsToShare)")
                            .font(.system(size: 14))
                        Text("\(invitation.listName)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    VStack {
                        TDButton(title: "\(Constants.Text.accept)",
                                 style: .primary,
                                 size: .custom(with: 100, height: 32)) {
                            acceptHandler(invitation.listId,
                                          invitation.documentId)
                        }
                        TDButton(title: "\(Constants.Text.decline)",
                                 style: .destructive,
                                 size: .custom(with: 100, height: 32)) {
                            declineHandler(invitation.documentId)
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Constants

private extension HomeInvitationsView {
    struct Constants {
        struct Text {
            static let invitations = "Invitations"
            static let wantsToShare = "Wants to share: "
            static let accept = "Accept"
            static let decline = "Decline"
        }
    }
}

#Preview {
    HomeInvitationsView(
        invitations: [],
        acceptHandler: { _, _ in},
        declineHandler: {_ in }
    )
}
