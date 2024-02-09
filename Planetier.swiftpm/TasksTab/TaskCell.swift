import SwiftUI
import SwiftData

struct TaskCell: View {
    
    @Environment(\.modelContext) var context
    
    let task: ToDoTask
    let edit: (ToDoTask) -> Void
    @State var isShowingSubtasks = false
    
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
                if task.subtasks.isEmpty == false {
                    Button {
                        isShowingSubtasks.toggle()
                    } label: {
                        Image(systemName: "chevron.up")
                            .rotationEffect(isShowingSubtasks ? .radians(.pi) : .zero)
                    }
                }
                Badge(
                    text: task.priority.uiText,
                    image: task.priority.uiImage,
                    style: task.priority.badgeStyle(for: task.priority)
                )
                if let deadline = task.deadline {
                    Text(TaskEditView<EmptyView>.dateFormatter.string(from: deadline))
                }
                if let estimation = task.estimation.map({ Int($0 / 60 / 60) }) {
                    Badge(text: estimation.estimationText)
                }
                Spacer()
            }
            if isShowingSubtasks && task.subtasks.isEmpty == false {
                VStack(alignment: .leading, spacing: -2) {
                    ForEach(task.subtasks) { subtask in
                        HStack(alignment: .center, spacing: 0) {
                            Checkbox(
                                isSelected: .init(
                                    get: { subtask.done },
                                    set: { newValue in
                                        task.subtasks.firstIndex(of: subtask)
                                            .map { task.subtasks[$0].done = newValue }
                                    }
                                )
                            )
                            .padding(.horizontal, .medium)
                            Text(subtask.name)
                                .padding(.vertical, .medium)
                            Spacer()
                        }
                        .bold()
                        .frame(height: .large * 2)
                        .background {
                            RoundedRectangle(cornerRadius: .defaultRadius)
                                .stroke(.black, lineWidth: 2.0)
                                .padding(1.0)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .transition(.opacity)
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
