import SwiftUI

@MainActor
protocol ItemsViewModel: ObservableObject {
    var items: [any ItemModel] { get }
    var options: (any ItemModel) -> [ItemOption] { get }
}

protocol ItemModel: Identifiable, Equatable, Hashable {
    var id: UUID { get }
    var documentId: String { get }
    var name: String { get }
    var done: Bool { get }
}

struct ItemOption: Identifiable {
    enum OptionType: String {
        case share = "Share"
        case done = "Done"
        case undone = "Undone"
        case delete = "Delete"
        
        var role: ButtonRole? {
            switch self {
            case .share: return nil
            case .done: return nil
            case .undone: return nil
            case .delete: return .destructive
            }
        }
    }
    
    let id = UUID()
    let type: OptionType
    let action: (any ItemModel) -> Void
}

struct ItemsView<ViewModel>: View where ViewModel: ItemsViewModel {
    @StateObject var viewModel: ViewModel
    var action: ((any ItemModel) -> Void)? = nil
    @State private var isShowingOptions = false
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                Group {
                    HStack {
                        Image(systemName: item.done ? "circle.fill" : "circle")
                            .foregroundColor(.backgroundPrimary)
                        Button(action: {
                            action?(item)
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
                                    options: viewModel.options)
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
            .padding([.leading, .trailing], -10)
            .scrollContentBackground(.hidden)
        }
    }
}

struct OptionsView: View {
    @State var isShowingOptions = false
    var item: any ItemModel
    var options: (any ItemModel) -> [ItemOption]
    
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
            ForEach(options(item),
                    id: \.id) { option in
                Button(option.type.rawValue,
                       role: option.type.role,
                       action: {
                    option.action(item)
                })
            }
        }
    }
}

#Preview {
    class ViewModel: ItemsViewModel {
        var items: [any ItemModel] = [ListModel(documentId: "",
                                                name: "Test",
                                                done: true,
                                                uuid: [],
                                                dateCreated: 0),
                                      ListModel(documentId: "",
                                                name: "Test2",
                                                done: false,
                                                uuid: [],
                                                dateCreated: 1)]
        
        var options: (any ItemModel) -> [ItemOption] = { _ in
            [ItemOption(type: .share,
                        action: { _ in })]
        }
    }
    return ItemsView(viewModel: ViewModel())
}
