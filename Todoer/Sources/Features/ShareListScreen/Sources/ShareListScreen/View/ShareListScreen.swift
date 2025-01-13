import SwiftUI
import Entities
import Application
import ThemeAssets
import ThemeComponents
import CoordinatorContract
import Mocks

// MARK: - ShareListView

struct ShareListScreen: View {
	@ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareOwnerNameText: String = ""
    @State private var shareEmailText: String = ""

	init(store: Store<ShareList.Reducer>) {
		self.store = store
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			title
			TDTextField(
				text: $shareOwnerNameText,
                placeholder: Constants.Text.shareOwnerNamePlaceholder
			)
            TDTextField(
                text: $shareEmailText,
                placeholder: Constants.Text.shareEmailPlaceholder
            )
			TDButton(title: Constants.Text.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue, $shareOwnerNameText.wrappedValue))
			}
			Text(Constants.Text.sharingWithTitle)
				.foregroundColor(Color.textBlack)
				.fontWeight(.medium)
				.padding(.top, 24)
				.padding(.bottom, 8)
			if store.state.viewModel.users.isEmpty {
				Text(Constants.Text.notSharedYet)
					.foregroundColor(Color.textBlack)
					.font(.system(size: 14))
			}
			else {
				ScrollView(.horizontal) {
					HStack(spacing: 20) {
						ForEach(store.state.viewModel.users) { user in
							VStack {
								AsyncImage(
									url: URL(string: user.photoUrl ?? ""),
									content: {
										$0.resizable().aspectRatio(
											contentMode: .fit
										)
									},
									placeholder: {
										Image.personCropCircle
											.tint(Color.buttonBlack)
									}
								)
								.frame(width: 30, height: 30)
								.cornerRadius(15.0)
								Text(user.displayName ?? "")
									.foregroundColor(Color.textBlack)
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
		.background(Color.backgroundWhite)
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

extension ShareListScreen {
	@ViewBuilder
	fileprivate var alertErrorMessage: Text? {
		if case let .error(error) = store.state.viewState {
			Text(error)
		}
	}

	@ViewBuilder
	fileprivate var title: some View {
		HStack {
			Image.squareAndArrowUp
				.foregroundColor(Color.backgroundBlack)
				.fontWeight(.medium)
			Text(Constants.Text.shareTitle)
				.foregroundColor(Color.textBlack)
				.fontWeight(.medium)
			Spacer()
		}
		.padding(.top, 24)
		.padding(.bottom, 8)
	}
}

// MARK: - Private

extension ShareListScreen {
	fileprivate var alertBinding: Binding<Bool> {
		Binding(
			get: {
				if case .error = store.state.viewState {
					return true
				}
				else {
					return false
				}
			},
			set: { _ in }
		)
	}
}

// MARK: - Constants

extension ShareListScreen {
	fileprivate struct Constants {
		struct Text {
			static let shareTitle = "Share"
			static let sharingWithTitle = "Sharing with"
			static let shareButtonTitle = "Share"
            static let shareOwnerNamePlaceholder = "Your name..."
			static let shareEmailPlaceholder = "Email to share with..."
			static let notSharedYet = "Not shared yet"
			static let errorTitle = "Error"
			static let errorOkButton = "Ok"
		}
	}
}

struct ShareView_Previews: PreviewProvider {
	static var previews: some View {
		ShareList.Builder.makeShareList(
			coordinator: CoordinatorMock(),
			list: UserList(
				documentId: "",
				name: "",
				done: true,
				uid: [],
				index: 0
			)
		)
	}
}
