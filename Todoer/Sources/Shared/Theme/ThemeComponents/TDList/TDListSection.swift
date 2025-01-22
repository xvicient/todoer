import SwiftUI
import Common
import Strings

public struct TDListSection: View {
    public typealias Content = () -> AnyView
    
    public struct Configuration {
        let title: String
        let addButtonTitle: String
        let isSortEnabled: Bool
        let isHeaderEnabled: Bool
        
        public init(
            title: String,
            addButtonTitle: String,
            isSortEnabled: Bool,
            isHeaderEnabled: Bool
        ) {
            self.title = title
            self.addButtonTitle = addButtonTitle
            self.isSortEnabled = isSortEnabled
            self.isHeaderEnabled = isHeaderEnabled
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
            TDListSectionButton(
                title: configuration.addButtonTitle,
                icon: Image.plusCircleFill
            ) {
                actions.onAddRow()
            }
            TDListSectionButton(
                title: Strings.List.sortButtonTitle,
                icon: Image.arrowUpArrowDownCircleFill
            ) {
                actions.onSortRows()
            }
            .disabled(!configuration.isSortEnabled)
        }
        .disabled(!configuration.isHeaderEnabled)
        .padding(.bottom, 12)
    }
}
