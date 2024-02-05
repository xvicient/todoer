import SwiftUI

struct ShareListView: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareEmailText: String = ""
    
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 12) {
            title
            TDTextField(text: $shareEmailText,
                        placeholder: Constants.Text.sharePlaceholder)
            TDButton(title: Constants.Text.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue))
            }
            .padding(.horizontal, 24)
            SwiftUI.List(store.state.viewModel.users) { user in
                Section(
                    header:
                        Text(Constants.Text.sharingWithTitle)
                        .foregroundColor(.textBlack)
                ) {
                    Text(user.displayName ?? "")
                        .foregroundColor(.textBlack)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
        }
        .padding(.top, 24)
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

private extension ShareListView {
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
            Text(Constants.Text.shareTitle)
                .foregroundColor(.textBlack)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
}

// MARK: - Private

private extension ShareListView {
    var alertBinding: Binding<Bool> {
        Binding(
            get: {
                { if case .error = store.state.viewState { return true } else { return false } }()
            },
            set: { _ in }
        )
    }
}

// MARK: - Constants

private extension ShareListView {
    struct Constants {
        struct Text {
            static let shareTitle = "Share"
            static let sharingWithTitle = "Sharing with"
            static let shareButtonTitle = "Share"
            static let sharePlaceholder = "Email..."
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
