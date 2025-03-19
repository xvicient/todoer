import SwiftUI
import Entities

public struct InvitationsToolbarView: View {
    
    @State private var isShowingInvitations: Bool = false
    @State private var sheetHeight: CGFloat = 0
    
    private var invitationsView: Home.MakeInvitationsView
    private let invitations: [Invitation]
    
    public init(
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView,
        invitations: [Invitation]
    ) {
        self.invitationsView = invitationsView
        self.invitations = invitations
    }
    
    public var body: some View {
        Button {
            isShowingInvitations = true
        } label: {
            Image.squareArrowDownFill
                .foregroundStyle(.black)
                .font(.system(size: 14))
                .padding(5)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .overlay(
                    Text("\(invitations.count)")
                        .font(.caption2).bold()
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.red))
                        .offset(x: 5, y: -3),
                    alignment: .topTrailing
                )
        }
        .sheet(isPresented: $isShowingInvitations, onDismiss: {
            isShowingInvitations = false
        }) {
            invitationsView(invitations)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            sheetHeight = geometry.size.height
                        }
                })
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
        }
        .padding(.trailing, -20)
    }
}
