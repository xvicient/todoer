import Strings
import SwiftUI
import ThemeAssets
import ThemeComponents
import xRedux

// MARK: - InvitationsView

struct InvitationsView: View {
    @Bindable private var store: Store<Invitations.Reducer>
    private let rowHeight: CGFloat = 90
    private var invitationsCount: Int
    
    init(
        store: Store<Invitations.Reducer>,
        invitationsCount: Int
    ) {
        self.store = store
        self.invitationsCount = invitationsCount
    }
    
    var body: some View {
        VStack {
            Text(Strings.Invitations.invitationsText)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .font(.largeTitle.bold())
                .padding()
            
            ScrollView {
                VStack {
                    ForEach(store.state.viewModel.invitations) { invitation in
                        Divider()
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
                                Text("\(Strings.Invitations.wantsToShareText)")
                                    .font(.system(size: 14))
                                Text("\(invitation.listName)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.textSecondary)
                            }
                            Spacer()
                            VStack {
                                TDBasicButton(
                                    title: "\(Strings.Invitations.acceptButtonTitle)",
                                    style: .primary,
                                    size: .custom(with: 100, height: 32)
                                ) {
                                    store.send(
                                        .didTapAcceptInvitation(
                                            invitation.listId,
                                            invitation.id
                                        )
                                    )
                                }
                                TDBasicButton(
                                    title: "\(Strings.Invitations.declineButtonTitle)",
                                    style: .destructive,
                                    size: .custom(with: 100, height: 32)
                                ) {
                                    store.send(
                                        .didTapDeclineInvitation(
                                            invitation.listId,
                                            invitation.id
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: max(rowHeight, CGFloat(invitationsCount) * rowHeight))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            store.send(.onViewAppear)
        }
    }
}
