import CoordinatorContract
import CoordinatorMocks
import Entities
import Foundation
import ShareListScreenContract
import Strings
import SwiftUI
import ThemeAssets
import ThemeComponents
import xRedux

// MARK: - ShareListView

struct ShareListScreen: View {
    @ObservedObject private var store: Store<ShareList.Reducer>
    @State private var shareOwnerNameText: String = ""
    @State private var shareEmailText: String = ""
    private var isShareButtonDisabled: Bool {
        !((!$shareEmailText.wrappedValue.isEmpty && !$shareOwnerNameText.wrappedValue.isEmpty)
            || (!$shareEmailText.wrappedValue.isEmpty && store.state.viewModel.selfName != nil))
    }

    init(store: Store<ShareList.Reducer>) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.ShareList.shareText)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .font(.largeTitle.bold())
                .padding(.vertical)
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
                store.send(
                    .didTapShareListButton(
                        $shareEmailText.wrappedValue,
                        $shareOwnerNameText.wrappedValue
                    )
                )
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
            } else {
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
        .background(Color.backgroundWhite)
        .onAppear {
            store.send(.onAppear)
        }
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
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
