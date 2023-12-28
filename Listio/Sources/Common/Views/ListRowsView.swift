import SwiftUI

@MainActor
protocol ListRowsViewModel: ObservableObject {
    var rows: [any ListRowsModel] { get }
    var options: (any ListRowsModel) -> [ListRowOption] { get }
}

protocol ListRowsModel: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get }
}

enum ListRowOption: String, Identifiable {
    case share = "Share"
    case done = "Done"
    case undone = "Undone"
    case delete = "Delete"
    
    var id: Self { self }
    
    var role: ButtonRole? {
        switch self {
        case .share: return nil
        case .done: return nil
        case .undone: return nil
        case .delete: return .destructive
        }
    }
}

struct ListRowsView<ViewModel>: View where ViewModel: ListRowsViewModel {
    @StateObject var viewModel: ViewModel
    var mainAction: ((any ListRowsModel) -> Void)? = nil
    var optionsAction: ((any ListRowsModel, ListRowOption) -> Void)? = nil
    @State private var isShowingOptions = false
    
    var body: some View {
        ForEach(viewModel.rows, id: \.id) { item in
            Group {
                HStack {
                    Image(systemName: item.done ? "circle.fill" : "circle")
                        .foregroundColor(.backgroundPrimary)
                    Button(action: {
                        mainAction?(item)
                    }) {
                        Text(item.name)
                            .strikethrough(item.done)
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.primary)
                    Spacer()
                    OptionsView(isShowingOptions: isShowingOptions,
                                item: item,
                                options: viewModel.options(item),
                                action: optionsAction)
                }
                .frame(height: 40)
                .listRowSeparator(.hidden)
            }
            .listRowBackground(
                Rectangle()
                    .fill(.backgroundSecondary)
                    .cornerRadius(10.0)
                    .padding([.top, .bottom], 5)
            )
        }
        .onDelete(perform: removeRows)
        .padding([.leading, .trailing], -10)
        .scrollContentBackground(.hidden)
    }
}

private extension ListRowsView {
    func removeRows(at offsets: IndexSet) {
        print("")
    }
}

struct OptionsView: View {
    @State var isShowingOptions = false
    var item: any ListRowsModel
    var options: [ListRowOption]
    var action: ((any ListRowsModel, ListRowOption) -> Void)?
    
    var body: some View {
        Button(action: {
            isShowingOptions = true
        }) {
            HStack {
                Spacer()
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.backgroundPrimary)
            }
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
        .confirmationDialog("",
                            isPresented: $isShowingOptions,
                            titleVisibility: .hidden) {
            ForEach(options,
                    id: \.id) { option in
                Button(option.rawValue,
                       role: option.role,
                       action: {
                    action?(item, option)
                })
            }
        }
    }
}

#Preview {
    class ViewModel: ListRowsViewModel {
        var rows: [any ListRowsModel] = [List(documentId: "",
                                              name: "Test",
                                              done: true,
                                              uuid: [],
                                              dateCreated: 0),
                                         List(documentId: "",
                                              name: "Test2",
                                              done: false,
                                              uuid: [],
                                              dateCreated: 1)]
        
        var options: (any ListRowsModel) -> [ListRowOption] = {
            [.share,
             $0.done ? .undone : .done,
             .delete]
        }
    }
    return ListRowsView(viewModel: ViewModel())
}
