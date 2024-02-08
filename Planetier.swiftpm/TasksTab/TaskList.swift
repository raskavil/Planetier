import SwiftUI
import SwiftData

struct TaskList: View {
    
    @Environment(\.modelContext) var context
    @Query var tasks: [ToDoTask]
    @State var editedTask: TaskEditViewInput?
    
    var body: some View {
        List(tasks) { task in
            TaskCell(task: task, edit: { editedTask = .edit($0) })
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "plus") {
                    editedTask = .new
                }
            }
        }
        .taskEditView(input: $editedTask)
    }
}

#Preview {
    NavigationStack {
        TaskList()
    }
}
