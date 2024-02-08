import SwiftUI
import SwiftData

struct TaskCell: View {
    
    @Environment(\.modelContext) var context
    
    let task: ToDoTask
    let edit: (ToDoTask) -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text(task.name).bold()
                Spacer(minLength: 4)
                Menu {
                    Menu("State") {
                        Button("To do") {}
                        Button("In progress") {}
                        Button("Done") {}
                    }
                    Button("Bookmark", systemImage: "bookmark") {}
                    Button("Edit", systemImage: "square.and.pencil") {
                        edit(task)
                    }
                    Button("Delete", systemImage: "trash") {
                        context.delete(task)
                    }
                } label: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            Image(systemName: "ellipsis")
                        }
                }
                .frame(width: .large, height: .large)
            }
            HStack {
                
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ToDoTask.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let task = ToDoTask(
        id: "preview",
        creationDate: .now,
        name: "Preview task",
        state: .progress,
        priority: .medium,
        subtasks: [.init(name: "Random subtask"), .init(name: "Random subtask 2")],
        estimation: nil,
        deadline: nil,
        calendarEventID: nil
    )
    return TaskCell(task: task, edit: { _ in })
        .modelContext(.init(container))
}
