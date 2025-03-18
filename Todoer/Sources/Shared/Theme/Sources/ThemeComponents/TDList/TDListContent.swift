import Common
import Strings
import SwiftUI

public struct TDListContent: View {
    public typealias Content = () -> AnyView

    public struct Configuration: TDFilledRowConfiguration {
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

    public struct Actions: TDFilledRowActions, TDEmptyRowActions {
        let onSubmit: (String) -> Void
        let onUpdate: (UUID, String) -> Void
        let onCancelAdd: () -> Void
        let onCancelEdit: (UUID) -> Void
        let onTap: ((UUID) -> Void)?
        let onSwipe: (UUID, TDSwipeAction) -> Void
        let onMove: (IndexSet, Int) -> Void

        public init(
            onSubmit: @escaping (String) -> Void,
            onUpdate: @escaping (UUID, String) -> Void,
            onCancelAdd: @escaping () -> Void,
            onCancelEdit: @escaping (UUID) -> Void,
            onTap: ((UUID) -> Void)? = nil,
            onSwipe: @escaping (UUID, TDSwipeAction) -> Void,
            onMove: @escaping (IndexSet, Int) -> Void
        ) {
            self.onSubmit = onSubmit
            self.onUpdate = onUpdate
            self.onCancelAdd = onCancelAdd
            self.onCancelEdit = onCancelEdit
            self.onTap = onTap
            self.onSwipe = onSwipe
            self.onMove = onMove
        }
    }

    private let configuration: Configuration
    private let actions: Actions
    @Binding private var rows: [TDListRow]

    public init(
        configuration: Configuration,
        actions: Actions,
        rows: Binding<[TDListRow]>
    ) {
        self.configuration = configuration
        self.actions = actions
        self._rows = rows
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
                if row.isEditing {
                    TDEmptyRowView(
                        row: row,
                        actions: actions,
                        text: $rows[index].name
                    )
                    .moveDisabled(!configuration.isMoveEnabled)
                    .id(index)
                }
                else {
                    TDFilledRowView(
                        row: row,
                        actions: actions,
                        configuration: configuration
                    )
                    .moveDisabled(!configuration.isMoveEnabled)
                    .id(index)
                }
            }
            .onMove(perform: actions.onMove)
//            .if(configuration.isMoveEnabled) {
//                $0.onMove(perform: actions.onMove)
//            }
        }
    }
}

#Preview {
    List {
        TDListContent(
            configuration: TDListContent.Configuration(
                isMoveEnabled: true,
                isSwipeEnabled: true,
                listHeight: 0.0
            ),
            actions: TDListContent.Actions(
                onSubmit: { _ in },
                onUpdate: { _, _ in },
                onCancelAdd: {} ,
                onCancelEdit: { _ in },
                onSwipe: { _, _ in },
                onMove: { _, _ in }),
            rows: .constant([])
        )
    }
    .scrollIndicators(.hidden)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
}
