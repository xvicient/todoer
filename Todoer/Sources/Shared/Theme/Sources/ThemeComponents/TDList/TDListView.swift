import SwiftUI

// MARK: - TDList

public struct TDListView: View {
    @Binding private var searchText: String
    @Binding private var isSearchFocused: Bool

    private let sections: () -> AnyView

    public init(
        @ViewBuilder sections: @escaping () -> AnyView,
        searchText: Binding<String>,
        isSearchFocused: Binding<Bool>
    ) {
        self.sections = sections
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
        .searchable(
            text: $searchText,
            isPresented: $isSearchFocused,
            placement: .navigationBarDrawer(displayMode: .always)
        )
    }
}
