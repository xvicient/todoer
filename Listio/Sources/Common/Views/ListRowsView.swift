import SwiftUI

// MARK: - ListRowsView

@MainActor
protocol ListRowsViewModel: ObservableObject {
    var rows: [any ListRow] { get }
    var leadingActions: (any ListRow) -> [ListRowAction] { get }
    var trailingActions: [ListRowAction] { get }
}

protocol ListRow: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get set }
    var isEditing: Bool { get }
}
enum ListRowAction: String, Identifiable {
    case share = "square.and.arrow.up"
    case done = "largecircle.fill.circle"
    case undone = "circle"
    case delete = "trash"
    
    var id: UUID { UUID() }
    
    var tint: Color {
        switch self {
        case .share: return .buttonPrimary
        case .done: return .backgroundPrimary
        case .undone: return .backgroundPrimary
        case .delete: return .red
        }
    }
}

struct ListRowsView<ViewModel>: View where ViewModel: ListRowsViewModel {
    @FocusState private var isEmptyRowFocused: Bool
    @State private var emptyRowText: String = ""
    
    @StateObject var viewModel: ViewModel
    
    var mainAction: ((any ListRow) -> Void)? = nil
    var swipeActions: ((Int, ListRowAction) -> Void)? = nil
    var submitAction: ((String) -> Void)? = nil
    var cancelAction: (() -> Void)? = nil
    var newRowPlaceholder: String = ""
    var cleanNewRowName: Bool = true
    
    var body: some View {
        ForEach(Array(viewModel.rows.enumerated()),
                id: \.element.id) { index, row in
            if row.isEditing {
                emptyRow
                .onAppear {
                    isEmptyRowFocused = true
                }
            } else {
                listRow(
                    row,
                    index: index
                )
            }
        }
    }
}

// MARK: - ViewBuilders

private extension ListRowsView {
    @ViewBuilder
    func listRow(
        _ row: any ListRow,
        index: Int
    ) -> some View {
        Group {
            HStack {
                Image(systemName: row.done ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(.backgroundPrimary)
                Button(action: {
                    mainAction?(row)
                }) {
                    Text(row.name)
                        .strikethrough(row.done)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .foregroundColor(.primary)
            }
            .frame(height: 40)
        }
        .swipeActions(edge: .leading) {
            swipeActions(
                actions: viewModel.leadingActions(row),
                index: index
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(
                actions: viewModel.trailingActions,
                index: index
            )
        }
    }
    
    @ViewBuilder
    var emptyRow: some View {
        HStack {
            Image(systemName: "circle")
                .foregroundColor(.backgroundPrimary)
            TextField(newRowPlaceholder, text: $emptyRowText)
                .foregroundColor(.primary)
                .focused($isEmptyRowFocused)
                .onAppear {
                    emptyRowText = cleanNewRowName ? "" : emptyRowText
                }
                .onSubmit {
                    hideKeyboard()
                    submitAction?($emptyRowText.wrappedValue)
                }
                .submitLabel(.done)
            Button(action: {
                cancelAction?()
            }) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.white)
            }
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func swipeActions(
        actions: [ListRowAction],
        index: Int
    ) -> some View {
        ForEach(actions,
                id: \.id) { option in
            Button {
                withAnimation {
                    swipeActions?(index, option)
                }
            } label: {
                Image(systemName: option.rawValue)
            }
            .tint(option.tint)
        }
    }
}

// MARK: - ListRow conforming

extension Item: ListRow {
    var isEditing: Bool {
        get { false }
    }
}

extension List: ListRow {
    var isEditing: Bool {
        get { false }
    }
}

#Preview {
    class ViewModel: ListRowsViewModel {
        var rows: [any ListRow] = [List(documentId: "",
                                              name: "Test",
                                              done: true,
                                              uuid: [],
                                              dateCreated: 0),
                                         List(documentId: "",
                                              name: "Test2",
                                              done: false,
                                              uuid: [],
                                              dateCreated: 1)]
        
        var leadingActions: (any ListRow) -> [ListRowAction] = {
            [$0.done ? .undone : .done]
        }
        
        var trailingActions: [ListRowAction] = [.share, .delete]
    }
    return ListRowsView(viewModel: ViewModel())
}
