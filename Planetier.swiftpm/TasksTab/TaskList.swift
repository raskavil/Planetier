import SwiftUI
import SwiftData

struct TaskList: View {
    
    @Environment(\.modelContext) var context
    @Query var tasks: [ToDoTask]
    
    @State var editedTask: TaskEditViewInput?
    @State var isEditingSort = false
    @State var presentedTaskToDelete: ToDoTask?
    @State var sorting: TaskSortInput = .init()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .medium) {
                SortedQueryForEach(sort: sorting.array.map(\.taskSortDescriptor)) { (task: ToDoTask) in
                    TaskCell(
                        task: task,
                        edit: { editedTask = .edit($0) },
                        delete: { presentedTaskToDelete = $0 }
                    )
                        .padding(.medium + .small)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding(2)
                        .padding(.horizontal, .default)
                        .transition(.opacity)
                        .clipped()
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "arrow.up.and.down.text.horizontal") {
                    isEditingSort = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "text.append") {
                    
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "plus") {
                    editedTask = .new
                }
            }
        }
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
                    context.delete(presentedTaskToDelete)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        TaskList()
    }
}
