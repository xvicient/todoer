import xRedux
import SwiftUI
import SwiftData
import ThemeAssets

struct ShareScreen: View {
    @ObservedObject private var store: Store<Share.Reducer>
    
    init(
        store: Store<Share.Reducer>
    ) {
        self.store = store
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                VStack(spacing: 24) {
                    HStack {
                        Button("Cancel", role: .destructive) {
                            store.send(.didTapCancel)
                        }
                        Spacer()
                        Text("New list")
                            .foregroundStyle(Color.textBlack)
                            .fontWeight(.bold)
                        Spacer()
                        Button("Save") {
                            store.send(.didTapSave)
                        }
                    }
                    Text(store.state.viewModel.content)
                        .foregroundStyle(Color.textBlack)
                }
                .padding(16)
                .background(Color.backgroundWhite)
                Spacer()
            }
            .frame(minHeight: UIScreen.main.bounds.height - 48)
            .padding(.horizontal, 32)
            .onAppear {
                store.send(.onViewAppear)
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .safeAreaPadding(.bottom, 48)
    }
}
