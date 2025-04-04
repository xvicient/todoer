import Common
import Strings
import SwiftUI

public enum TDContentStatus {
    case plain, editing, adding
}

public struct TDListContentView: View {
    public typealias Content = () -> AnyView

    public struct Configuration {
        let listHeight: CGFloat
        let status: TDContentStatus

        public init(
            listHeight: CGFloat,
            status: TDContentStatus
        ) {
            self.listHeight = listHeight
            self.status = status
        }
    }

    public struct Actions: TDListFilledRowActions, TDListEditRowActions, TDListAddRowActions {
        let onSubmit: (String?, String) -> Void
        let onCancel: () -> Void
        let onTap: ((String) -> Void)?
        let onSwipe: (String, TDListSwipeAction) -> Void
        let onMove: (IndexSet, Int) -> Void

        public init(
            onSubmit: @escaping (String?, String) -> Void,
            onCancel: @escaping () -> Void,
            onTap: ((String) -> Void)? = nil,
            onSwipe: @escaping (String, TDListSwipeAction) -> Void,
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
            emptyView
        } else {
            switch configuration.status {
            case .plain, .adding:
                if configuration.status == .adding {
                    TDListAddRowView(
                        actions: actions
                    )
                    .id("TDListAddRowView")
                    .moveDisabled(true)
                }
                ForEach(Array($rows.enumerated()), id: \.offset) { _, $row in
                    TDListFilledRowView(
                        row: row,
                        actions: actions
                    )
                    .id(row.id)
                    .moveDisabled(true)
                }
                .onMove(perform: actions.onMove)
            case .editing:
                ForEach(Array($rows.enumerated()), id: \.offset) { _, $row in
                    TDListEditRowView(
                        row: $row,
                        actions: actions
                    )
                    .id(row.id)
                    .moveDisabled(false)
                }
                .onMove(perform: actions.onMove)
            }
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
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
    }
}

#Preview {
    List {
        TDListContentView(
            configuration: TDListContentView.Configuration(
                listHeight: 0.0,
                status: .plain
            ),
            actions: TDListContentView.Actions(
                onSubmit: { _, _ in },
                onCancel: {} ,
                onSwipe: { _, _ in },
                onMove: { _, _ in }),
            rows: .constant([])
        )
    }
    .scrollIndicators(.hidden)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
}
