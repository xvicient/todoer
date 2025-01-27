import Application
import SwiftUI
import SwiftData

struct ShareScreen: View {
    @ObservedObject private var store: Store<Share.Reducer>
    
    init(
        store: Store<Share.Reducer>
    ) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                HStack {
                    Button("Cancel") {
                        store.send(.didTapCancel)
                    }
                    Spacer()
                    Button("Save") {
                        store.send(.didTapSave)
                    }
                }
                Text(store.state.viewModel.content)
                    .foregroundStyle(Color.black)
            }
            .padding(16)
            .background(Color.white)
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            store.send(.onViewAppear)
        }
        .background(Color.clear)
    }
}
