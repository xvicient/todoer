import SwiftUI

struct TDNewRowView: View {
    private let row: Home.Reducer.ListRow
    private let onSubmit: (String) -> Void
    private let onUpdate: (String) -> Void
    private let onCancelAdd: () -> Void
    private let onCancelEdit: () -> Void
    @FocusState private var isNewRowFocused: Bool
    @State private var newRowText = ""
    
    init(
        row: Home.Reducer.ListRow,
        onSubmit: @escaping (String) -> Void,
        onUpdate: @escaping (String) -> Void,
        onCancelAdd: @escaping () -> Void,
        onCancelEdit: @escaping () -> Void) {
            self.row = row
            self.onSubmit = onSubmit
            self.onUpdate = onUpdate
            self.onCancelAdd = onCancelAdd
            self.onCancelEdit = onCancelEdit
        }
    
    var body: some View {
        HStack {
            (row.list.done ? Image.largecircleFillCircle : Image.circle)
                .foregroundColor(.buttonBlack)
            TextField(Constants.Text.list, text: $newRowText)
                .foregroundColor(.textBlack)
                .focused($isNewRowFocused)
                .onAppear {
                    newRowText = row.list.name
                }
                .onSubmit {
                    hideKeyboard()
                    if row.list.name.isEmpty {
                        onSubmit($newRowText.wrappedValue)
                    } else {
                        onUpdate($newRowText.wrappedValue)
                    }
                }
                .submitLabel(.done)
            Button(action: {
                hideKeyboard()
                if row.list.name.isEmpty {
                    onCancelAdd()
                } else {
                    onCancelEdit()
                }
            }) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.buttonBlack)
            }
            .buttonStyle(.borderless)
        }
        .frame(height: 40)
        .listRowInsets(.init(top: 8,
                             leading: 8,
                             bottom: 8,
                             trailing: 8))
        .onAppear {
            isNewRowFocused = true
        }
    }
}

// MARK: - TDNewRow

private extension TDNewRowView {
    struct Constants {
        struct Text {
            static let list = "List..."
        }
    }
}
