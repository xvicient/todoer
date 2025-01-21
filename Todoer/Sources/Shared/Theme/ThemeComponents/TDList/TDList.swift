import SwiftUI

// MARK: - TDList

public struct TDList: View {    
    @Binding private var searchText: String
    @Binding private var isSearchFocused: Bool
    
    private let isEditing: Bool
    private let sections: () -> AnyView
    
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
