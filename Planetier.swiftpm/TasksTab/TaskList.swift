import SwiftUI
import SwiftData

struct TaskList: View {
    
    @Environment(\.modelContext) var context
    @Query var tasks: [ToDoTask]
    @State var editedTask: TaskEditViewInput?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .medium) {
                ForEach(tasks) { task in
                    TaskCell(task: task, edit: { editedTask = .edit($0) })
                        .padding(.medium + .small)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding(2)
                        .padding(.horizontal, .default)
                        .clipped()
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "arrow.up.and.down.text.horizontal") {
                    
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
    }
}

#Preview {
    NavigationStack {
        TaskList()
    }
}
