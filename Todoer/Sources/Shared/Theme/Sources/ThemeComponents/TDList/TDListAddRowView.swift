import Strings
import SwiftUI

protocol TDListAddRowActions {
    var onSubmit: (String?, String) -> Void { get }
    var onCancel: () -> Void { get }
}

struct TDListAddRowView: View {
    private let actions: TDListAddRowActions

    @FocusState private var isFocused: Bool
    @State private var text: String = ""

    init(
        actions: TDListAddRowActions
    ) {
        self.actions = actions
    }

    var body: some View {
        HStack {
            Image.circle
                .foregroundColor(Color.buttonBlack)
            
            TextField(Strings.List.newItemPlaceholder, text: $text)
                .focused($isFocused)
                .foregroundColor(Color.textBlack)
                .submitLabel(.done)
                .onSubmit(handleSubmit)
            
            Button(action: handleCancel) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.buttonBlack)
            }
            .buttonStyle(.borderless)
        }
        .frame(height: 40)
        .onAppear {
            isFocused = true
        }
    }

    // Handle submit action
    private func handleSubmit() {
        hideKeyboard()
        withAnimation {
            actions.onSubmit(nil, text)
        }
    }

    // Handle cancel action
    private func handleCancel() {
        hideKeyboard()
        withAnimation {
            actions.onCancel()
        }
    }
}
