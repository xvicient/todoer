import Strings
import SwiftUI

protocol TDListAddRowActions {
    var onSubmit: (String?, String) -> Void { get }
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
            
            if !text.isEmpty && isFocused {
                Button(action: handleCancel) {
                    Image.xmark
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.buttonBlack)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(height: 40)
        .onAppear {
            text = ""
            isFocused = true
        }
    }

    private func handleSubmit() {
        hideKeyboard()
        withAnimation {
            actions.onSubmit(nil, text)
        }
    }

    private func handleCancel() {
        text = ""
    }
}
