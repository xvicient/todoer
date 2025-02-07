import SwiftUI

// MARK: - TDList

/// A custom list component that supports searching and editing functionality
/// Used as the main container for displaying lists of items in the app
public struct TDList: View {    
    @Binding private var searchText: String
    @Binding private var isSearchFocused: Bool
    
    private let isEditing: Bool
    private let sections: () -> AnyView
    
    /// Creates a new list view
    /// - Parameters:
    ///   - sections: ViewBuilder closure that returns the list sections
    ///   - isEditing: Whether the list is in editing mode
    ///   - searchText: Binding to the search text
    ///   - isSearchFocused: Binding to track if search is focused
    public init(
        @ViewBuilder sections: @escaping () -> AnyView,
        isEditing: Bool,
        searchText: Binding<String>,
        isSearchFocused: Binding<Bool>
    ) {
        self.sections = sections
        self.isEditing = isEditing
        self._searchText = searchText
        self._isSearchFocused = isSearchFocused
    }

    public var body: some View {
        List {
            sections()
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .if(!isEditing) {
            $0.searchable(
                text: $searchText,
                isPresented: $isSearchFocused,
                placement: .navigationBarDrawer(displayMode: .always)
            )
        }
    }
}
