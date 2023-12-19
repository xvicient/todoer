import SwiftUI

@MainActor
protocol ItemsRowViewModel: ObservableObject {
    var items: [any ItemRowModel] { get }
    var options: (any ItemRowModel) -> [ItemRowOption] { get }
}

protocol ItemRowModel: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get }
}

enum ItemRowOption: String, Identifiable {
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

struct ItemsRowView<ViewModel>: View where ViewModel: ItemsRowViewModel {
    @StateObject var viewModel: ViewModel
    var mainAction: ((any ItemRowModel) -> Void)? = nil
    var optionsAction: ((any ItemRowModel, ItemRowOption) -> Void)? = nil
    @State private var isShowingOptions = false
    
    var body: some View {
        ForEach(viewModel.items, id: \.id) { item in
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

private extension ItemsRowView {
    func removeRows(at offsets: IndexSet) {
        print("")
    }
}

struct OptionsView: View {
    @State var isShowingOptions = false
    var item: any ItemRowModel
    var options: [ItemRowOption]
    var action: ((any ItemRowModel, ItemRowOption) -> Void)?
    
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
    class ViewModel: ItemsRowViewModel {
        var items: [any ItemRowModel] = [List(documentId: "",
                                              name: "Test",
                                              done: true,
                                              uuid: [],
                                              dateCreated: 0),
                                         List(documentId: "",
                                              name: "Test2",
                                              done: false,
                                              uuid: [],
                                              dateCreated: 1)]
        
        var options: (any ItemRowModel) -> [ItemRowOption] = {
            [.share,
             $0.done ? .undone : .done,
             .delete]
        }
    }
    return ItemsRowView(viewModel: ViewModel())
}
