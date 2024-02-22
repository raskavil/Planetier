import SwiftUI

struct GroupList: View {
    
    @Environment(\.modelContext) var modelContext
    @State var editInput: GroupEditViewInput?
    @State var editedTask: TaskEditViewInput?
    @State var isEditingSort = false
    @State var presentedTaskToDelete: ToDoTask?
    @State var presentedGroupToDelete: Group?
    @State var sorting: TaskSortInput = .userDefaultsValue ?? .init() {
        didSet {
            do { try sorting.saveToUserDefaults() }
            catch { assertionFailure(error.localizedDescription) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .medium) {
                QueryForEach { group in
                    GroupCell(
                        group: group,
                        delete: { presentedGroupToDelete = $0 },
                        edit: { editInput = .edit($0) },
                        editTask: { editedTask = .edit($0) },
                        deleteTask: { presentedTaskToDelete = $0 }
                    )
                        .clipShape(RoundedRectangle(cornerRadius: .defaultRadius))
                        .clipped()
                }
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(height: .default)
            }
            .padding(.horizontal, .default)
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "arrow.up.and.down.text.horizontal") {
                    isEditingSort = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(systemImage: "plus") {
                    editInput = .new
                }
            }
        }
        .groupEditView(input: $editInput)
        .taskEditView(input: $editedTask)
        .taskSortView(isPresented: $isEditingSort, input: sorting, save: { newValue in withAnimation { sorting = newValue } })
        .dialog(
            isPresented: .init(
                get: { presentedTaskToDelete != nil },
                set: { presentedTaskToDelete = $0 ? presentedTaskToDelete : nil }
            ),
            accessoryView: Image("delete", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150),
            title: "Delete",
            text: "Do you really want to permanently delete this task?",
            buttonTitle: "Delete",
            buttonStyle: .init(backgroundColor: .red),
            confirmation: {
                if let presentedTaskToDelete {
                    self.presentedTaskToDelete = nil
                    modelContext.delete(presentedTaskToDelete)
                }
            }
        )
        .dialog(
            isPresented: .init(
                get: { presentedGroupToDelete != nil },
                set: { presentedGroupToDelete = $0 ? presentedGroupToDelete : nil }
            ),
            accessoryView: Image("delete", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150),
            title: "Delete",
            text: "Do you really want to permanently delete this group?",
            buttonTitle: "Delete",
            buttonStyle: .init(backgroundColor: .red),
            confirmation: {
                if let presentedGroupToDelete {
                    self.presentedGroupToDelete = nil
                    modelContext.delete(presentedGroupToDelete)
                }
            }
        )
    }
}

#Preview {
    GroupList()
}
