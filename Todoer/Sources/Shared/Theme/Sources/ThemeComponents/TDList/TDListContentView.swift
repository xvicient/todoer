import Common
import Strings
import SwiftUI

public struct TDListContentView: View {
    public typealias Content = () -> AnyView

    public struct Configuration: TDListFilledRowConfiguration {
        let lineLimit: Int?
        let isMoveEnabled: Bool
        let isSwipeEnabled: Bool
        let listHeight: CGFloat

        public init(
            lineLimit: Int? = nil,
            isMoveEnabled: Bool,
            isSwipeEnabled: Bool,
            listHeight: CGFloat
        ) {
            self.lineLimit = lineLimit
            self.isMoveEnabled = isMoveEnabled
            self.isSwipeEnabled = isSwipeEnabled
            self.listHeight = listHeight
        }
    }

    public struct Actions: TDListFilledRowActions, TDListEditRowActions {
        let onSubmit: (UUID, String) -> Void
        let onCancel: () -> Void
        let onTap: ((UUID) -> Void)?
        let onSwipe: (UUID, TDListSwipeAction) -> Void
        let onMove: (IndexSet, Int) -> Void

        public init(
            onSubmit: @escaping (UUID, String) -> Void,
            onCancel: @escaping () -> Void,
            onTap: ((UUID) -> Void)? = nil,
            onSwipe: @escaping (UUID, TDListSwipeAction) -> Void,
            onMove: @escaping (IndexSet, Int) -> Void
        ) {
            self.onSubmit = onSubmit
            self.onCancel = onCancel
            self.onTap = onTap
            self.onSwipe = onSwipe
            self.onMove = onMove
        }
    }

    private let configuration: Configuration
    private let actions: Actions
    @Binding private var rows: [TDListRow]
    @Binding private var editMode: EditMode

    public init(
        configuration: Configuration,
        actions: Actions,
        rows: Binding<[TDListRow]>,
        editMode: Binding<EditMode>
    ) {
        self.configuration = configuration
        self.actions = actions
        self._rows = rows
        self._editMode = editMode
    }

    public var body: some View {
        if rows.isEmpty {
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
            .frame(height: (configuration.listHeight - 145) < 0 ? 0 : (configuration.listHeight - 145)
            )
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        } else {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if row.isEditing || editMode.isEditing {
                    TDListEditRowView(
                        row: $rows[index],
                        actions: actions
                    )
                    .moveDisabled(!configuration.isMoveEnabled)
                    .id(index)
                }
                else {
                    TDListFilledRowView(
                        row: row,
                        actions: actions,
                        configuration: configuration
                    )
                    .moveDisabled(!configuration.isMoveEnabled)
                    .id(index)
                }
            }
            .onMove(perform: actions.onMove)
        }
    }
}

#Preview {
    List {
        TDListContentView(
            configuration: TDListContentView.Configuration(
                isMoveEnabled: true,
                isSwipeEnabled: true,
                listHeight: 0.0
            ),
            actions: TDListContentView.Actions(
                onSubmit: { _, _ in },
                onCancel: {} ,
                onSwipe: { _, _ in },
                onMove: { _, _ in }),
            rows: .constant([]),
            editMode: .constant(.inactive)
        )
    }
    .scrollIndicators(.hidden)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
}
