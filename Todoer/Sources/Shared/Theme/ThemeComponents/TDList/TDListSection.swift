import SwiftUI
import Common
import Strings

/// A section component for displaying lists in a consistent format
/// Provides a standardized way to show lists with headers and content
public struct TDListSection: View {
    public typealias Content = () -> AnyView
    
    /// Configuration for a list section
    public struct Configuration {
        let title: String
        let addButtonTitle: String
        let isDisabled: Bool
        let isEditMode: Bool
        
        /// Creates a new configuration for a list section
        /// - Parameters:
        ///   - title: The title of the section
        ///   - addButtonTitle: The title for the add button
        ///   - isDisabled: Whether the section is disabled
        ///   - isEditMode: Whether the section is in edit mode
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
    
    /// Actions that can be performed on a list section
    public struct Actions {
        let onAddRow: () -> Void
        let onSortRows: () -> Void
        
        /// Creates a new actions configuration
        /// - Parameters:
        ///   - onAddRow: Closure called when the add button is tapped
        ///   - onSortRows: Closure called when the sort button is tapped
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
    
    /// Creates a new list section
    /// - Parameters:
    ///   - content: ViewBuilder closure that returns the section content
    ///   - configuration: Configuration for the section
    ///   - actions: Actions for the section
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
                title: Strings.List.sortButtonTitle,
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
