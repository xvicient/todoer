import Common
import Strings
import SwiftUI
import ThemeAssets
import xRedux

// MARK: - TDListView

/// The list UI shared by every `TDListSharedReducer` screen (Home, ListItems, …): the
/// collapsing header + tabbed, searchable, editable, reorderable list, plus the error alert and
/// edit-mode wiring. Screen-specific chrome (invitations toolbar, scene-phase handling, loading
/// presentation) stays in each screen and is applied as modifiers around this view.
///
/// The shared row mechanics (submit / toggle / delete / move) are dispatched here via
/// `R.shared(...)`; only the behaviours that differ per screen are injected:
/// - `title`: static (Home) or per-list (ListItems).
/// - `onAppear`: the screen's own appear action.
/// - `onTap`: row navigation (Home) or `nil` (ListItems, rows are not navigable).
/// - `onShare`: the `.share` swipe (Home) or `nil` (ListItems, no share action).
public struct TDListView<R: TDListSharedReducer>: View
    where R.State: AppAlertState, R.State.Action == R.Action {

    @Bindable private var store: Store<R>
    private let title: String
    private let onAppear: () -> Void
    private let onTap: ((String) -> Void)?
    private let onShare: ((String) -> Void)?

    public init(
        store: Store<R>,
        title: String,
        onAppear: @escaping () -> Void,
        onTap: ((String) -> Void)? = nil,
        onShare: ((String) -> Void)? = nil
    ) {
        self.store = store
        self.title = title
        self.onAppear = onAppear
        self.onTap = onTap
        self.onShare = onShare
    }

    public var body: some View {
        GeometryReader { geometry in
            TDListContentView(
                title: title,
                tabs: $store.tabs,
                activeTab: $store.activeTab,
                searchText: $store.searchText,
                isSearchFocused: $store.isSearchFocused
            ) {
                listContent(geometry.size.height)
            }
        }
        .environment(\.editMode, $store.editMode)
        .onAppear {
            onAppear()
        }
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}

// MARK: - List content

extension TDListView {
    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> some View {
        let status = store.contentStatus

        if store.rows.isEmpty && status != .adding {
            emptyView(listHeight)
        } else {
            rowsContent(status)
        }
    }

    @ViewBuilder
    private func rowsContent(_ status: TDContentStatus) -> some View {
        switch status {
        case .plain, .adding:
            if status == .adding {
                TDListAddRowView(
                    onSubmit: { store.send(R.shared(.didTapSubmitButton(nil, $0))) }
                )
                .id("TDListAddRowView")
                .moveDisabled(true)
            }
            ForEach(Array($store.rows.enumerated()), id: \.offset) { _, $row in
                TDListFilledRowView(
                    row: row,
                    onTap: onTap,
                    onSwipe: onSwipe
                )
                .id(row.id)
                .moveDisabled(true)
            }
            .onMove(perform: onMove)
        case .editing:
            ForEach(Array($store.rows.enumerated()), id: \.offset) { _, $row in
                TDListEditRowView(
                    row: $row,
                    onSubmit: { store.send(R.shared(.didTapSubmitButton($0, $1))) }
                )
                .id(row.id)
                .moveDisabled(false)
            }
            .onMove(perform: onMove)
        }
    }

    @ViewBuilder
    private func emptyView(_ listHeight: CGFloat) -> some View {
        VStack {
            Spacer()
            Image.questionmarkDashed
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray.opacity(0.6))

            Text(Strings.List.noResults)
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(height: (listHeight - 145) < 0 ? 0 : (listHeight - 145))
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }

    private var onSwipe: (String, TDListSwipeAction) -> Void {
        { rowId, option in
            switch option {
            case .done, .undone:
                store.send(R.shared(.didTapToggleButton(rowId)))
            case .delete:
                store.send(R.shared(.didTapDeleteButton(rowId)))
            case .share:
                onShare?(rowId)
            }
        }
    }

    private func onMove(_ from: IndexSet, _ to: Int) {
        store.send(R.shared(.didMove(from, to)))
    }
}

// MARK: - Rows

private struct TDListFilledRowView: View {
    let row: TDListRow
    let onTap: ((String) -> Void)?
    let onSwipe: (String, TDListSwipeAction) -> Void

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)
            Button(action: { onTap?(row.id) }) {
                TDURLText(text: row.name)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .strikethrough(row.done)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.textBlack)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .frame(minHeight: 40)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            swipeActions(row.leadingActions)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(row.trailingActions)
        }
    }

    @ViewBuilder
    private func swipeActions(_ actions: [TDListSwipeAction]) -> some View {
        ForEach(actions) { action in
            Button(role: action.role) {
                withAnimation {
                    onSwipe(row.id, action)
                }
            } label: {
                action.icon
            }
            .tint(action.tint)
        }
    }
}

private struct TDListEditRowView: View {
    @Binding var row: TDListRow
    let onSubmit: (String?, String) -> Void

    @Binding private var text: String
    @State private var localText: String = ""
    @FocusState private var isFocused: Bool

    init(
        row: Binding<TDListRow>,
        onSubmit: @escaping (String?, String) -> Void
    ) {
        self._row = row
        self.onSubmit = onSubmit
        self._text = row.name
    }

    var body: some View {
        HStack {
            row.image
                .foregroundColor(Color.buttonBlack)

            TextField(Strings.List.newItemPlaceholder, text: $localText)
                .focused($isFocused)
                .foregroundColor(Color.textBlack)
                .submitLabel(.done)
                .onSubmit(handleSubmit)
                .onChange(of: text) {
                    if localText != text {
                        localText = text
                    }
                }

            if !localText.isEmpty && isFocused {
                Button(action: handleCancel) {
                    Image.xmark
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.buttonBlack)
                }
            }
        }
        .frame(height: 40)
        .onAppear {
            localText = text
        }
    }

    private func handleSubmit() {
        hideKeyboard()
        text = localText
        withAnimation {
            onSubmit(row.id, localText)
        }
    }

    private func handleCancel() {
        localText = ""
    }
}

private struct TDListAddRowView: View {
    let onSubmit: (String) -> Void

    @FocusState private var isFocused: Bool
    @State private var text: String = ""

    var body: some View {
        HStack {
            Image.circle
                .foregroundColor(Color.buttonBlack)

            TextField(Strings.List.newItemPlaceholder, text: $text)
                .focused($isFocused)
                .foregroundColor(Color.textBlack)
                .submitLabel(.done)
                .onSubmit(handleSubmit)

            if !text.isEmpty && isFocused {
                Button(action: handleCancel) {
                    Image.xmark
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.buttonBlack)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(height: 40)
        .onAppear {
            text = ""
            isFocused = true
        }
    }

    private func handleSubmit() {
        hideKeyboard()
        withAnimation {
            onSubmit(text)
        }
    }

    private func handleCancel() {
        text = ""
    }
}
