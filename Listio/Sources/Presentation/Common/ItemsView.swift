import SwiftUI

@MainActor
protocol ItemsViewModel: ObservableObject {
    var items: [any ItemModel] { get }
    var options: [ItemOption] { get }
}

protocol ItemModel: Identifiable {
    var id: String? { get }
    var name: String { get }
    var done: Bool { get }
}

struct ItemOption: Identifiable {
    enum OptionType: String {
        case share = "Share"
        case done = "Done"
        case delete = "Delete"
        
        var role: ButtonRole? {
            switch self {
            case .share: return nil
            case .done: return nil
            case .delete: return .destructive
            }
        }
    }
    
    let id = UUID()
    let type: OptionType
    let action: (String?) -> Void
}

struct ItemsView<ViewModel>: View where ViewModel: ItemsViewModel {
    @StateObject var viewModel: ViewModel
    var action: ((String?, String) -> Void)? = nil
    @State private var isShowingOptions = false
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                HStack {
                    Image(systemName: item.done ? "circle.fill" : "circle")
                        .foregroundColor(.backgroundPrimary)
                    Button(action: {
                        action?(item.id, item.name)
                    }) {
                        Text(item.name)
                            .frame(maxWidth: .infinity, 
                                   alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.primary)
                    Spacer()
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
                        ForEach(viewModel.options,
                                id: \.type.rawValue) { option in
                            Button(option.type.rawValue,
                                   role: option.type.role,
                                   action: {
                                option.action(item.id)
                            })
                        }
                    }
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

#Preview {
    ItemsView(
        viewModel: HomeViewModel(
            listsRepository: ListsRepository()
        ))
}
