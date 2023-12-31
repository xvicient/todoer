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
    var done: Bool { get }
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
    @StateObject var viewModel: ViewModel
    var mainAction: ((any ListRow) -> Void)? = nil
    var swipeActions: ((any ListRow, ListRowAction) -> Void)? = nil
    
    var body: some View {
        ForEach(viewModel.rows, id: \.id) { item in
            Group {
                HStack {
                    Image(systemName: item.done ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(.backgroundPrimary)
                    Button(action: {
                        mainAction?(item)
                    }) {
                        Text(item.name)
                            .strikethrough(item.done)
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
                    actions: viewModel.leadingActions(item),
                    item: item
                )
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                swipeActions(
                    actions: viewModel.trailingActions,
                    item: item
                )
            }
        }
    }
}

// MARK: - ViewBuilders

private extension ListRowsView {
    @ViewBuilder
    func swipeActions(
        actions: [ListRowAction],
        item: any ListRow
    ) -> some View {
        ForEach(actions,
                id: \.id) { option in
            Button {
                withAnimation {
                    swipeActions?(item, option)
                }
            } label: {
                Image(systemName: option.rawValue)
            }
            .tint(option.tint)
        }
    }
}

// MARK: - ListRow conforming

extension Item: ListRow {}

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
