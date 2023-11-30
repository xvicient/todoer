import SwiftUI

@MainActor
protocol ItemsViewModel: ObservableObject {
    var items: [any ItemModel] { get }
    var options: [ItemOption] { get }
}

protocol ItemModel: Identifiable {
    var id: UUID { get }
    var documentId: String? { get }
    var name: String { get }
    var done: Bool { get }
}

struct ItemOption: Identifiable {
    enum OptionType: String {
        case share = "Share"
        case doneUndone = "Done/Undone"
        case delete = "Delete"
        
        var role: ButtonRole? {
            switch self {
            case .share: return nil
            case .doneUndone: return nil
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
    var action: ((String?, String) -> Void)? = nil
    @State private var isShowingOptions = false
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                Group {
                    HStack {
                        Image(systemName: item.done ? "circle.fill" : "circle")
                            .foregroundColor(.backgroundPrimary)
                        Button(action: {
                            action?(item.documentId, item.name)
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
                        .padding([.top, .bottom], 5))
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct OptionsView: View {
    @State var isShowingOptions = false
    var item: any ItemModel
    var options: [ItemOption]
    
    var body: some View {
        Button(action: {
            isShowingOptions = true
        }) {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .contentShape(Rectangle())
                .foregroundColor(.backgroundPrimary)
        }
        .confirmationDialog("",
                            isPresented: $isShowingOptions,
                            titleVisibility: .hidden) {
            ForEach(options,
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
    ItemsView(
        viewModel: HomeViewModel(
            listsRepository: ListsRepository()
        ))
}
