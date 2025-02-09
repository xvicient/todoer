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
    @State private var emptyRowText = ""

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            TextField(Strings.List.newItemPlaceholder, text: $emptyRowText)
                .foregroundColor(Color.textBlack)
                .focused($isEmptyRowFocused)
                .onAppear {
                    emptyRowText = row.name
                }
                .onSubmit {
                    hideKeyboard()
                    withAnimation {
                        if row.name.isEmpty {
                            actions.onSubmit($emptyRowText.wrappedValue)
                        }
                        else {
                            actions.onUpdate(row.id, $emptyRowText.wrappedValue)
                        }
                    }
                }
                .submitLabel(.done)
            Button(action: {
                hideKeyboard()
                withAnimation {
                    if row.name.isEmpty {
                        actions.onCancelAdd()
                    }
                    else {
                        actions.onCancelEdit(row.id)
                    }
                }
            }) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.buttonBlack)
            }
            .buttonStyle(.borderless)
        }
        .frame(height: 40)
        .listRowInsets(
            .init(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        )
        .onAppear {
            isEmptyRowFocused = true
        }
    }
}
