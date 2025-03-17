import Strings
import SwiftUI

protocol TDEmptyRowActions {
    var onSubmit: (String) -> Void { get }
    var onUpdate: (UUID, String) -> Void { get }
    var onCancelAdd: () -> Void { get }
    var onCancelEdit: (UUID) -> Void { get }
}

struct TDEmptyRowView: View {
    @ObservedObject var row: TDListRow
    let actions: TDEmptyRowActions

    @FocusState private var isEmptyRowFocused: Bool
    @Binding private var text: String
    @State private var localText: String = ""

    init(
        row: TDListRow,
        actions: TDEmptyRowActions,
        text: Binding<String>
    ) {
        self.row = row
        self.actions = actions
        self._text = text
    }

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            
            TextField(Strings.List.newItemPlaceholder, text: $localText)
                .foregroundColor(Color.textBlack)
                .focused($isEmptyRowFocused)
                .onSubmit(handleSubmit)
                .onChange(of: text) {
                    if localText != text {
                        localText = text
                    }
                }
                .submitLabel(.done)
            
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
            isEmptyRowFocused = true
            localText = text
        }
    }

    // Handle submit action
    private func handleSubmit() {
        hideKeyboard()
        text = localText
        withAnimation {
            if row.name.isEmpty {
                actions.onSubmit(localText)
            } else {
                actions.onUpdate(row.id, localText)
            }
        }
    }

    // Handle cancel action
    private func handleCancel() {
        hideKeyboard()
        withAnimation {
            if row.name.isEmpty {
                actions.onCancelAdd()
            } else {
                actions.onCancelEdit(row.id)
                localText = text
            }
        }
    }
}
