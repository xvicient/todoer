import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var coordinator: Coordinator<AppRouter>
    @State private var isShowingOptions = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ZStack {
                List {
                    ForEach(viewModel.lists, id: \.self) { list in
                        HStack {
                            Image(systemName: list.done ? "circle.fill" : "circle")
                                .foregroundColor(.backgroundPrimary)
                            Button(action: {
                                coordinator.show(.products(list.id ?? "", list.name))
                            }) {
                                Text(list.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            .confirmationDialog("", isPresented: $isShowingOptions,
                                                titleVisibility: .hidden) {
                                Button(ListOptions.share.rawValue) {
                                    viewModel.addMember(to: list)
                                }
                                Button(ListOptions.markAsDone.rawValue) {
                                    viewModel.addMember(to: list)
                                }
                                Button(ListOptions.delete.rawValue, role: .destructive) {
                                    viewModel.addMember(to: list)
                                }
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.primary)
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
                .task {
                    viewModel.fetchLists()
                }
                .scrollContentBackground(.hidden)
                VStack {
                    Spacer()
                    Button(action: {
                        // Show add list
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 48.0, height: 48.0)
                    })
                    .foregroundColor(.buttonPrimary)
                }
            }
            .disabled(viewModel.isLoading)
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Your todoos")
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        listsRepository: ListsRepository()))
}
