import Strings
import SwiftUI

protocol TDEmptyRowActions {
    var onSubmit: (String) -> Void { get }
    var onCancel: () -> Void { get }
}

struct TDEmptyRowView: View {
    @Binding var row: TDListRow
    let actions: TDEmptyRowActions

    @FocusState private var isEmptyRowFocused: Bool
    @Binding private var text: String
    @State private var localText: String = ""

    init(
        row: Binding<TDListRow>,
        actions: TDEmptyRowActions
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
                .foregroundColor(Color.textBlack)
                .submitLabel(.done)
                .onSubmit(handleSubmit)
                .if(row.isEditing) {
                    $0.focused($isEmptyRowFocused)
                }
                .onChange(of: text) {
                    if localText != text {
                        localText = text
                    }
                }
            
            if row.isEditing {
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
            if row.isEditing {
                isEmptyRowFocused = true
            }
            localText = text
        }
    }

    // Handle submit action
    private func handleSubmit() {
        hideKeyboard()
        text = localText
        withAnimation {
            actions.onSubmit(localText)
        }
    }

    // Handle cancel action
    private func handleCancel() {
        hideKeyboard()
        withAnimation {
            actions.onCancel()
            localText = text
        }
    }
}
