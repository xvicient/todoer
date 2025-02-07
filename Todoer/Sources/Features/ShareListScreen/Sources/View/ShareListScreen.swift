import Foundation
import SwiftUI
import CoordinatorMocks
import Entities
import Application
import ThemeAssets
import ThemeComponents
import CoordinatorContract
import Entities
import ShareListScreenContract
import Strings

// MARK: - ShareListView

/// Main view for sharing a list with other users
/// This view provides a form for entering sharing details and displays current shared users
struct ShareListScreen: View {
    /// Store managing the state and actions
    @ObservedObject private var store: Store<ShareList.Reducer>
    /// Text field value for the owner's name
    @State private var shareOwnerNameText: String = ""
    /// Text field value for the recipient's email
    @State private var shareEmailText: String = ""
    
    /// Determines if the share button should be disabled
    /// Returns true if required fields are empty
    private var isShareButtonDisabled: Bool {
        !((!$shareEmailText.wrappedValue.isEmpty &&
           !$shareOwnerNameText.wrappedValue.isEmpty) ||
        (!$shareEmailText.wrappedValue.isEmpty &&
         store.state.viewModel.selfName != nil))
    }

    /// Initializes a new ShareListScreen
    /// - Parameter store: Store managing the screen's state and actions
    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			title
            if store.state.viewModel.selfName == nil {
                TDTextField(
                    text: $shareOwnerNameText,
                    placeholder: Strings.ShareList.shareOwnerNamePlaceholder
                )
            }
            TDTextField(
                text: $shareEmailText,
                placeholder: Strings.ShareList.shareEmailPlaceholder
            )
			TDBasicButton(title: Strings.ShareList.shareButtonTitle) {
                store.send(.didTapShareListButton($shareEmailText.wrappedValue, $shareOwnerNameText.wrappedValue))
            }
            .disabled(isShareButtonDisabled)
			Text(Strings.ShareList.sharingWithText)
				.foregroundColor(Color.textBlack)
				.fontWeight(.medium)
				.padding(.top, 24)
				.padding(.bottom, 8)
			if store.state.viewModel.users.isEmpty {
                Text(Strings.ShareList.notSharedYetText)
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
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
	}
}

// MARK: - ViewBuilders

extension ShareListScreen {
    /// Title view for the share screen
    @ViewBuilder
    fileprivate var title: some View {
		HStack {
			Image.squareAndArrowUp
				.foregroundColor(Color.backgroundBlack)
				.fontWeight(.medium)
            Text(Strings.ShareList.shareText)
				.foregroundColor(Color.textBlack)
				.fontWeight(.medium)
			Spacer()
		}
		.padding(.top, 24)
		.padding(.bottom, 8)
	}
}

struct ShareView_Previews: PreviewProvider {
    struct Dependencies: ShareListScreenDependencies {
        let coordinator: CoordinatorApi
        let list: UserList
    }
    
    static var previews: some View {
        ShareList.Builder.makeShareList(
            dependencies: Dependencies(
                coordinator: CoordinatorMock(),
                list: UserList(
                    id: UUID(),
                    documentId: "",
                    name: "",
                    done: true,
                    uid: [],
                    index: 0
                )
            )
        )
    }
}
