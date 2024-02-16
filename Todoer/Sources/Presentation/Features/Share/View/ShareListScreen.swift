import SwiftUI

// MARK: - ShareListView

struct ShareListScreen: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareEmailText: String = ""
    
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            title
            TDTextField(text: $shareEmailText,
                        placeholder: Constants.Text.sharePlaceholder)
            TDButton(title: Constants.Text.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue))
            }
            Text(Constants.Text.sharingWithTitle)
                .foregroundColor(.textBlack)
                .fontWeight(.medium)
                .padding(.top, 24)
                .padding(.bottom, 8)
            if store.state.viewModel.users.isEmpty {
                Text(Constants.Text.notSharedYet)
                    .foregroundColor(.textBlack)
                    .font(.system(size: 14))
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(store.state.viewModel.users) { user in
                            VStack {
                                AsyncImage(
                                    url: URL(string: user.photoUrl ?? ""),
                                    content: {
                                        $0.resizable().aspectRatio(contentMode: .fit)
                                    }, placeholder: {
                                        Image.personCropCircle
                                            .tint(.buttonBlack)
                                    })
                                .frame(width: 30, height: 30)
                                .cornerRadius(15.0)
                                Text(user.displayName ?? "")
                                    .foregroundColor(.textBlack)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity)
        .background(.backgroundWhite)
        .onAppear {
            store.send(.onAppear)
        }
        .alert(isPresented: alertBinding) {
            Alert(
                title: Text(Constants.Text.errorTitle),
                message: alertErrorMessage,
                dismissButton: .default(Text(Constants.Text.errorOkButton)) {
                    store.send(.didTapDismissError)
                }
            )
        }
    }
}

// MARK: - ViewBuilders

private extension ShareListScreen {
    @ViewBuilder
    var alertErrorMessage: Text? {
        if case let .error(error) = store.state.viewState {
            Text(error)
        }
    }
    
    @ViewBuilder
    var title: some View {
        HStack {
            Image.squareAndArrowUp
                .foregroundColor(.backgroundBlack)
                .fontWeight(.medium)
            Text(Constants.Text.shareTitle)
                .foregroundColor(.textBlack)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

// MARK: - Private

private extension ShareListScreen {
    var alertBinding: Binding<Bool> {
        Binding(
            get: {
                if case .error = store.state.viewState { return true } else { return false }
            },
            set: { _ in }
        )
    }
}

// MARK: - Constants

private extension ShareListScreen {
    struct Constants {
        struct Text {
            static let shareTitle = "Share"
            static let sharingWithTitle = "Sharing with"
            static let shareButtonTitle = "Share"
            static let sharePlaceholder = "Email..."
            static let notSharedYet = "Not shared yet"
            static let errorTitle = "Error"
            static let errorOkButton = "Ok"
        }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareList.Builder.makeShareList(
            coordinator: Coordinator(),
            list: List(
                documentId: "",
                name: "",
                done: true,
                uid: [],
                index: 0
            )
        )
    }
}
