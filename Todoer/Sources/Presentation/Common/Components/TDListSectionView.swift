import SwiftUI

// MARK: - TDListSectionView

@MainActor
protocol TDListSectionViewModel: ObservableObject {
    var rows: [any TDSectionRow] { get }
    var leadingActions: (any TDSectionRow) -> [TDSectionRowActionType] { get }
    var trailingActions: [TDSectionRowActionType] { get }
}

protocol TDSectionRow: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get set }
    var isEditing: Bool { get }
}

protocol TDSectionRowActions {
    var tapAction: ((Int) -> Void)? { get }
    var swipeActions: ((Int, TDSectionRowActionType) -> Void)? { get }
    var submitAction: ((String) -> Void)? { get }
    var cancelAction: (() -> Void)? { get }
}

enum TDSectionRowActionType: Identifiable {
    case share
    case done
    case undone
    case delete
    
    var id: UUID { UUID() }
    
    var tint: Color {
        switch self {
        case .share: return .buttonBlack
        case .done: return .buttonBlack
        case .undone: return .buttonBlack
        case .delete: return .buttonDestructive
        }
    }
    
    var icon: Image {
        switch self {
        case .share: return .squareAndArrowUp
        case .done: return .largecircleFillCircle
        case .undone: return .circle
        case .delete: return .trash
        }
    }
}

struct TDListSectionView<ViewModel>: View where ViewModel: TDListSectionViewModel {
    @FocusState private var isNewRowFocused: Bool
    @State private var newRowText = ""
    
    @StateObject var viewModel: ViewModel
    var actions: TDSectionRowActions
    var sectionTitle = ""
    var newRowPlaceholder = ""
    
    var body: some View {
        Section(
            header: header(title: sectionTitle)
        ) {
            ForEach(Array(viewModel.rows.enumerated()),
                    id: \.element.id) { index, row in
                if row.isEditing {
                    newRow(index)
                } else {
                    sectionRow(row, index: index )
                }
            }
        }
    }
}

// MARK: - ViewBuilders

private extension TDListSectionView {
    @ViewBuilder
    func header(
        title: String
    ) -> some View {
        if !sectionTitle.isEmpty {
            Text(sectionTitle)
                .foregroundColor(.textWhite)
        }
    }
    
    @ViewBuilder
    func sectionRow(
        _ row: any TDSectionRow,
        index: Int
    ) -> some View {
        Group {
            HStack {
                (row.done ? Image.largecircleFillCircle : Image.circle)
                .foregroundColor(.buttonBlack)
                Button(action: {
                    actions.tapAction?(index)
                }) {
                    Text(row.name)
                        .strikethrough(row.done)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .foregroundColor(.textBlack)
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
    func newRow(_ index: Int) -> some View {
        HStack {
            Image.circle
                .foregroundColor(.buttonBlack)
            TextField(newRowPlaceholder, text: $newRowText)
                .foregroundColor(.textBlack)
                .focused($isNewRowFocused)
                .onAppear {
                    newRowText = ""
                }
                .onSubmit {
                    hideKeyboard()
                    actions.submitAction?($newRowText.wrappedValue)
                }
                .submitLabel(.done)
            Button(action: {
                withAnimation {
                    actions.cancelAction?()
                }
            }) {
                Image.xmark
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.buttonBlack)
            }
        }
        .frame(height: 40)
        .id(index)
        .onAppear {
            isNewRowFocused = true
        }
    }
    
    @ViewBuilder
    func swipeActions(
        of types: [TDSectionRowActionType],
        index: Int
    ) -> some View {
        ForEach(types,
                id: \.id) { option in
            Button {
                withAnimation {
                    actions.swipeActions?(index, option)
                }
            } label: {
                option.icon
            }
            .tint(option.tint)
        }
    }
}

// MARK: - SectionRow conforming

extension Item: TDSectionRow {
    var isEditing: Bool {
        get { false }
    }
}

extension List: TDSectionRow {
    var isEditing: Bool {
        get { false }
    }
}

#Preview {
    class ViewModel: TDListSectionViewModel {
        var rows: [any TDSectionRow] = [List(documentId: "",
                                           name: "Test",
                                           done: true,
                                           uuid: [],
                                           dateCreated: 0),
                                      List(documentId: "",
                                           name: "Test2",
                                           done: false,
                                           uuid: [],
                                           dateCreated: 1)]
        
        var leadingActions: (any TDSectionRow) -> [TDSectionRowActionType] = {
            [$0.done ? .undone : .done]
        }
        
        var trailingActions: [TDSectionRowActionType] = [.share, .delete]
    }
    
    struct ListActions: TDSectionRowActions {
        var tapAction: ((Int) -> Void)?
        var swipeActions: ((Int, TDSectionRowActionType) -> Void)?
        var submitAction: ((String) -> Void)?
        var cancelAction: (() -> Void)?
    }
    
    return TDListSectionView(viewModel: ViewModel(),
                             actions: ListActions())
}
