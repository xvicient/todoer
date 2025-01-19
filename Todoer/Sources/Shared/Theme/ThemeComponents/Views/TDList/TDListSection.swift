import SwiftUI
import Common

public struct TDListSection: View {
    private var content: () -> AnyView
    private let title: String
    private let addButtonTitle: String
    private let isDisabled: Bool
    private let isEditMode: Bool
    private let onAddRow: () -> Void
    private let onSortRows: () -> Void
    
    @State private var searchText = ""
    @State private var isSearchFocused = false
    
    public init(
        @ViewBuilder content: @escaping () -> AnyView,
        title: String,
        addButtonTitle: String,
        isDisabled: Bool,
        isEditMode: Bool,
        onAddRow: @escaping () -> Void,
        onSortRows: @escaping () -> Void
    ) {
        self.content = content
        self.title = title
        self.addButtonTitle = addButtonTitle
        self.isDisabled = isDisabled
        self.isEditMode = isEditMode
        self.onAddRow = onAddRow
        self.onSortRows = onSortRows
    }
    
    public var body: some View {
        Section(header: Text(title).listRowHeaderStyle()) {
            header()
            content()
        }
    }
    
    @ViewBuilder
    private func header() -> some View {
        HStack {
            TDActionButton(
                title: addButtonTitle,
                icon: Image.plusCircleFill
            ) {
                onAddRow()
            }
            TDActionButton(
                title: Constants.Text.sortButtonTitle,
                icon: Image.arrowUpArrowDownCircleFill
            ) {
                onSortRows()
            }
            .disabled(isDisabled)
        }
        .disabled(
            isEditMode ||
            isSearchFocused
        )
        .padding(.bottom, 12)
    }
}


private extension TDListSection {
    struct Constants {
        struct Text {
            static let sortButtonTitle = "Sort"
        }
    }
}
