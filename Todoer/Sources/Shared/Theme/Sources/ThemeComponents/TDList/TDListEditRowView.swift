import Strings
import SwiftUI

protocol TDListEditRowActions {
    var onSubmit: (String?, String) -> Void { get }
}

struct TDListEditRowView: View {
    @Binding var row: TDListRow
    let actions: TDListEditRowActions

    @Binding private var text: String
    @State private var localText: String = ""
    @FocusState private var isFocused: Bool

    init(
        row: Binding<TDListRow>,
        actions: TDListEditRowActions
    ) {
        self._row = row
        self.actions = actions
        self._text = row.name
    }

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            
            TextField(Strings.List.newItemPlaceholder, text: $localText)
                .focused($isFocused)
                .foregroundColor(Color.textBlack)
                .submitLabel(.done)
                .onSubmit(handleSubmit)
                .onChange(of: text) {
                    if localText != text {
                        localText = text
                    }
                }
            
            if !localText.isEmpty && isFocused {
                Button(action: handleCancel) {
                    Image.xmark
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.buttonBlack)
                }
            }
        }
        .frame(height: 40)
        .onAppear {
            localText = text
        }
    }

    private func handleSubmit() {
        hideKeyboard()
        text = localText
        withAnimation {
            actions.onSubmit(row.id, localText)
        }
    }
    
    private func handleCancel() {
        localText = ""
    }
}
