import SwiftUI
import Common

public struct TDListSection: View {
    public typealias Content = () -> AnyView
    
    public struct Configuration {
        let title: String
        let addButtonTitle: String
        let isDisabled: Bool
        let isEditMode: Bool
        
        public init(
            title: String,
            addButtonTitle: String,
            isDisabled: Bool,
            isEditMode: Bool
        ) {
            self.title = title
            self.addButtonTitle = addButtonTitle
            self.isDisabled = isDisabled
            self.isEditMode = isEditMode
        }
    }
    
    public struct Actions {
        let onAddRow: () -> Void
        let onSortRows: () -> Void
        
        public init(
            onAddRow: @escaping () -> Void,
            onSortRows: @escaping () -> Void
        ) {
            self.onAddRow = onAddRow
            self.onSortRows = onSortRows
        }
    }
    
    private var content: Content
    private let configuration: Configuration
    private let actions: Actions
    
    @State private var searchText = ""
    @State private var isSearchFocused = false
    
    public init(
        @ViewBuilder content: @escaping Content,
        configuration: Configuration,
        actions: Actions
    ) {
        self.content = content
        self.configuration = configuration
        self.actions = actions
    }
    
    public var body: some View {
        Section(header: Text(configuration.title).listRowHeaderStyle()) {
            header()
            content()
        }
    }
    
    @ViewBuilder
    private func header() -> some View {
        HStack {
            TDActionButton(
                title: configuration.addButtonTitle,
                icon: Image.plusCircleFill
            ) {
                actions.onAddRow()
            }
            TDActionButton(
                title: Constants.Text.sortButtonTitle,
                icon: Image.arrowUpArrowDownCircleFill
            ) {
                actions.onSortRows()
            }
            .disabled(configuration.isDisabled)
        }
        .disabled(
            configuration.isEditMode ||
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
