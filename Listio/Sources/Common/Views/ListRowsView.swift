import SwiftUI

// MARK: - ListRowsView

@MainActor
protocol ListRowsViewModel: ObservableObject {
    var rows: [any ListRow] { get }
    var leadingActions: (any ListRow) -> [ListRowActionType] { get }
    var trailingActions: [ListRowActionType] { get }
}

protocol ListRow: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get set }
    var isEditing: Bool { get }
}

protocol ListRowsViewActions {
    var tapAction: ((any ListRow) -> Void)? { get }
    var swipeActions: ((Int, ListRowActionType) -> Void)? { get }
    var submitAction: ((String) -> Void)? { get }
    var cancelAction: (() -> Void)? { get }
}

enum ListRowActionType: String, Identifiable {
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
    var actions: ListRowsViewActions?
    var newRowPlaceholder: String = ""
    
    var body: some View {
        ForEach(Array(viewModel.rows.enumerated()),
                id: \.element.id) { index, row in
            if row.isEditing {
                emptyRow(index)
            } else {
                listRow(row, index: index )
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
                    actions?.tapAction?(row)
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
                of: viewModel.leadingActions(row),
                index: index
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(
                of: viewModel.trailingActions,
                index: index
            )
        }
        .id(index)
    }
    
    @ViewBuilder
    func emptyRow(_ index: Int) -> some View {
        HStack {
            Image(systemName: "circle")
                .foregroundColor(.backgroundPrimary)
            TextField(newRowPlaceholder, text: $emptyRowText)
                .foregroundColor(.primary)
                .focused($isEmptyRowFocused)
                .onAppear {
                    emptyRowText = ""
                }
                .onSubmit {
                    hideKeyboard()
                    actions?.submitAction?($emptyRowText.wrappedValue)
                }
                .submitLabel(.done)
            Button(action: {
                withAnimation {
                    actions?.cancelAction?()
                }
            }) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.black)
            }
        }
        .frame(height: 40)
        .id(index)
        .onAppear {
            isEmptyRowFocused = true
        }
    }
    
    @ViewBuilder
    func swipeActions(
        of types: [ListRowActionType],
        index: Int
    ) -> some View {
        ForEach(types,
                id: \.id) { option in
            Button {
                withAnimation {
                    actions?.swipeActions?(index, option)
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
        
        var leadingActions: (any ListRow) -> [ListRowActionType] = {
            [$0.done ? .undone : .done]
        }
        
        var trailingActions: [ListRowActionType] = [.share, .delete]
    }
    return ListRowsView(viewModel: ViewModel())
}
